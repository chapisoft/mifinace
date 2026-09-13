package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CollectRepaymentRequest;
import com.bmf.mobile.app.dto.response.RepaymentReceiptResponse;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.RepaymentTransaction;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.DistributedLockPort;
import com.bmf.mobile.domain.repository.LoanRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.bmf.mobile.domain.repository.RepaymentRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CollectRepaymentUseCaseTest {

    @Mock
    private RepaymentRepository repaymentRepository;

    @Mock
    private LoanRepository loanRepository;

    @Mock
    private OutboxEventRepository outboxEventRepository;

    @Mock
    private DistributedLockPort distributedLockPort;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private CollectRepaymentUseCase collectRepaymentUseCase;

    private CollectRepaymentRequest validRequest;
    private GroupScheduleRecord activeSchedule;

    @BeforeEach
    void setUp() {
        validRequest = CollectRepaymentRequest.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .periodNumber(1)
                .principalAmount(new BigDecimal("50000.00"))
                .interestAmount(new BigDecimal("6250.00"))
                .insuranceFee(new BigDecimal("1000.00"))
                .compulsorySaving(new BigDecimal("2000.00"))
                .penaltyAmount(BigDecimal.ZERO)
                .totalAmount(new BigDecimal("59250.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-TX-001")
                .offlineTimestamp("2026-09-15T09:30:00")
                .notes("Thu tien mat")
                .build();

        activeSchedule = GroupScheduleRecord.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .groupCode("GRP-YGN-01")
                .periodNumber(1)
                .principalAmount(new BigDecimal("50000.00"))
                .interestAmount(new BigDecimal("6250.00"))
                .insuranceFee(new BigDecimal("1000.00"))
                .compulsorySaving(new BigDecimal("2000.00"))
                .totalAmount(new BigDecimal("59250.00"))
                .status("PENDING")
                .build();
    }

    @Test
    @DisplayName("Gạch nợ tín dụng thành công - Lưu giao dịch, sinh Outbox Event và cập nhật trạng thái COLLECTED")
    void collectSuccessShouldSaveTransactionAndOutboxEvent() throws Exception {
        when(repaymentRepository.findByIdempotencyKey("IDEM-TX-001")).thenReturn(Optional.empty());

        when(distributedLockPort.executeWithLock(anyString(), anyLong(), anyLong(), any(TimeUnit.class), org.mockito.ArgumentMatchers.<Supplier<RepaymentReceiptResponse>>any()))
                .thenAnswer(invocation -> {
                    Supplier<?> action = invocation.getArgument(4);
                    return action.get();
                });

        when(loanRepository.findScheduleByContractAndPeriod("HD-2026-001", 1))
                .thenReturn(Optional.of(activeSchedule));

        when(objectMapper.writeValueAsString(any())).thenReturn("{\"mock\":\"payload\"}");

        RepaymentReceiptResponse response = collectRepaymentUseCase.collect(validRequest, "USR001");

        assertNotNull(response);
        assertEquals("HD-2026-001", response.getContractCode());
        assertEquals("CUST-001", response.getCustomerCode());
        assertEquals(1, response.getPeriodNumber());
        assertEquals(new BigDecimal("59250.00"), response.getPaidAmount());
        assertEquals(RepaymentMethod.CASH, response.getPaymentMethod());
        assertEquals(RepaymentStatus.COLLECTED, response.getStatus());

        verify(repaymentRepository).save(any(RepaymentTransaction.class));
        verify(outboxEventRepository).save(any(OutboxEvent.class));
        verify(loanRepository).updateScheduleStatus("HD-2026-001", 1, "COLLECTED", new BigDecimal("59250.00"));
    }

    @Test
    @DisplayName("Bẫy Idempotency - Gửi lại cùng Idempotency Key trả về biên lai giao dịch cũ mà không xử lý 2 lần")
    void collectDuplicateIdempotencyKeyShouldReturnExistingTransaction() {
        RepaymentTransaction existingTx = RepaymentTransaction.builder()
                .transactionId("TX-EXISTING-001")
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .periodNumber(1)
                .totalAmount(new BigDecimal("59250.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .status(RepaymentStatus.COLLECTED)
                .collectedTime(LocalDateTime.parse("2026-09-15T09:30:00"))
                .collectedBy("USR001")
                .idempotencyKey("IDEM-TX-001")
                .build();

        when(repaymentRepository.findByIdempotencyKey("IDEM-TX-001")).thenReturn(Optional.of(existingTx));

        RepaymentReceiptResponse response = collectRepaymentUseCase.collect(validRequest, "USR001");

        assertNotNull(response);
        assertEquals("TX-EXISTING-001", response.getTransactionId());
        assertEquals("HD-2026-001", response.getContractCode());
        assertEquals(new BigDecimal("59250.00"), response.getPaidAmount());

        verify(distributedLockPort, never()).executeWithLock(anyString(), anyLong(), anyLong(), any(TimeUnit.class), org.mockito.ArgumentMatchers.<Supplier<RepaymentReceiptResponse>>any());
    }

    @Test
    @DisplayName("Gạch nợ thất bại - Kỳ nợ đã được tất toán (SETTLED) ném lỗi ERR_TRANSACTION_ALREADY_SETTLED")
    void collectAlreadySettledScheduleShouldThrowException() {
        when(repaymentRepository.findByIdempotencyKey("IDEM-TX-001")).thenReturn(Optional.empty());

        when(distributedLockPort.executeWithLock(anyString(), anyLong(), anyLong(), any(TimeUnit.class), org.mockito.ArgumentMatchers.<Supplier<RepaymentReceiptResponse>>any()))
                .thenAnswer(invocation -> {
                    Supplier<?> action = invocation.getArgument(4);
                    return action.get();
                });

        GroupScheduleRecord settledSchedule = GroupScheduleRecord.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .periodNumber(1)
                .status("SETTLED")
                .build();

        when(loanRepository.findScheduleByContractAndPeriod("HD-2026-001", 1))
                .thenReturn(Optional.of(settledSchedule));

        BusinessException ex = assertThrows(BusinessException.class,
                () -> collectRepaymentUseCase.collect(validRequest, "USR001"));

        assertEquals(ErrorCode.ERR_TRANSACTION_ALREADY_SETTLED, ex.getErrorCode());
        verify(repaymentRepository, never()).save(any());
    }

    @Test
    @DisplayName("Gạch nợ thất bại - Không tìm thấy hợp đồng vay ném lỗi ERR_LOAN_NOT_FOUND")
    void collectNotFoundScheduleShouldThrowException() {
        when(repaymentRepository.findByIdempotencyKey("IDEM-TX-001")).thenReturn(Optional.empty());

        when(distributedLockPort.executeWithLock(anyString(), anyLong(), anyLong(), any(TimeUnit.class), org.mockito.ArgumentMatchers.<Supplier<RepaymentReceiptResponse>>any()))
                .thenAnswer(invocation -> {
                    Supplier<?> action = invocation.getArgument(4);
                    return action.get();
                });

        when(loanRepository.findScheduleByContractAndPeriod("HD-2026-001", 1))
                .thenReturn(Optional.empty());

        BusinessException ex = assertThrows(BusinessException.class,
                () -> collectRepaymentUseCase.collect(validRequest, "USR001"));

        assertEquals(ErrorCode.ERR_LOAN_NOT_FOUND, ex.getErrorCode());
    }
}
