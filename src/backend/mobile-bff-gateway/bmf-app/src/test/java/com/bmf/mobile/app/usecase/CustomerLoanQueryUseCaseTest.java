package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.response.CustomerLoanSummaryResponse;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.repository.CustomerRepository;
import com.bmf.mobile.domain.repository.LoanRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CustomerLoanQueryUseCaseTest {

    @Mock
    private LoanRepository loanRepository;

    @Mock
    private CustomerRepository customerRepository;

    @InjectMocks
    private CustomerLoanQueryUseCase customerLoanQueryUseCase;

    private CustomerMember customer;
    private GroupScheduleRecord paidPeriod;
    private GroupScheduleRecord unpaidPeriod;

    @BeforeEach
    void setUp() {
        customer = CustomerMember.builder()
                .customerCode("CUST-001")
                .fullName("Daw Khin Myint")
                .groupCode("GRP-YGN-01")
                .build();

        paidPeriod = GroupScheduleRecord.builder()
                .contractCode("HD-001")
                .customerCode("CUST-001")
                .periodNumber(1)
                .principalAmount(new BigDecimal("50000.00"))
                .status("SETTLED")
                .build();

        unpaidPeriod = GroupScheduleRecord.builder()
                .contractCode("HD-001")
                .customerCode("CUST-001")
                .periodNumber(2)
                .principalAmount(new BigDecimal("50000.00"))
                .status("PENDING")
                .build();
    }

    @Test
    @DisplayName("Khách hàng tra cứu hợp đồng thành công - Tính toán đúng tổng dư nợ và số kỳ thanh toán")
    void getLoanSummarySuccessShouldReturnCustomerLoanSummary() {
        when(customerRepository.findByCustomerCode("CUST-001")).thenReturn(Optional.of(customer));
        when(loanRepository.findSchedulesByCustomerCode("CUST-001")).thenReturn(List.of(paidPeriod, unpaidPeriod));

        CustomerLoanSummaryResponse response = customerLoanQueryUseCase.getLoanSummary("CUST-001");

        assertNotNull(response);
        assertEquals("CUST-001", response.getCustomerCode());
        assertEquals("Daw Khin Myint", response.getFullName());
        assertEquals(new BigDecimal("50000.00"), response.getTotalOutstandingPrincipal());
        assertEquals(1, response.getTotalPeriodsPaid());
        assertEquals(1, response.getTotalPeriodsRemaining());
        assertEquals(2, response.getSchedules().size());
    }

    @Test
    @DisplayName("Khách hàng tra cứu thất bại khi không tìm thấy hồ sơ khách hàng")
    void getLoanSummaryCustomerNotFoundShouldThrowException() {
        when(customerRepository.findByCustomerCode("NON_EXISTENT")).thenReturn(Optional.empty());

        BusinessException ex = assertThrows(BusinessException.class,
                () -> customerLoanQueryUseCase.getLoanSummary("NON_EXISTENT"));

        assertEquals(ErrorCode.ERR_USER_NOT_FOUND, ex.getErrorCode());
    }
}
