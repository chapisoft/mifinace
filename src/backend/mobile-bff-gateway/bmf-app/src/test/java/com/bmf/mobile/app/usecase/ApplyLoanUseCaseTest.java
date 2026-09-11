package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.ApplyLoanRequest;
import com.bmf.mobile.app.dto.response.LoanApplicationResponse;
import com.bmf.mobile.domain.entity.LoanApplication;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.LoanApplicationStatus;
import com.bmf.mobile.domain.repository.LoanApplicationRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ApplyLoanUseCaseTest {

    @Mock
    private LoanApplicationRepository loanApplicationRepository;

    @Mock
    private OutboxEventRepository outboxEventRepository;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private ApplyLoanUseCase applyLoanUseCase;

    private ApplyLoanRequest validRequest;

    @BeforeEach
    void setUp() {
        validRequest = ApplyLoanRequest.builder()
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .nrcNumber("12/DAGAMA(N)045612")
                .groupCode("GRP-YGN-01")
                .loanProductCode("MICRO_BIZ_01")
                .requestedAmount(new BigDecimal("500000.00"))
                .termMonths(12)
                .purpose("Mo rong sap hang tap hoa")
                .gpsLatitude(new BigDecimal("16.8660694"))
                .gpsLongitude(new BigDecimal("96.1951234"))
                .nrcFrontImageUrl("https://storage.bmf.mm/nrc_f.jpg")
                .signatureImageUrl("https://storage.bmf.mm/sign.png")
                .surveyImageUrl("https://storage.bmf.mm/survey.jpg")
                .build();
    }

    @Test
    @DisplayName("Nộp hồ sơ vay vốn thành công - Chấm điểm tín dụng đạt chuẩn và sinh Outbox Event")
    void applyLoanSuccessShouldSaveApplicationAndOutboxEvent() throws Exception {
        when(objectMapper.writeValueAsString(any())).thenReturn("{\"mock\":\"payload\"}");

        LoanApplicationResponse response = applyLoanUseCase.apply(validRequest, "USR001");

        assertNotNull(response);
        assertNotNull(response.getApplicationId());
        assertEquals("CUST-001", response.getCustomerCode());
        assertEquals("Daw Khin Myint", response.getCustomerName());
        assertEquals(new BigDecimal("500000.00"), response.getRequestedAmount());
        assertEquals(12, response.getTermMonths());
        assertEquals(LoanApplicationStatus.SUBMITTED, response.getStatus());
        assertTrue(response.getCreditScore() >= 600);

        verify(loanApplicationRepository).save(any(LoanApplication.class));
        verify(outboxEventRepository).save(any(OutboxEvent.class));
    }
}
