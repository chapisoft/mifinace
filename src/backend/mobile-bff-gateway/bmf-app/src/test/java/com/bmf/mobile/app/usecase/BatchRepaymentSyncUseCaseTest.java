package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.BatchRepaymentSyncRequest;
import com.bmf.mobile.app.dto.request.CollectRepaymentRequest;
import com.bmf.mobile.app.dto.response.BatchSyncSummaryResponse;
import com.bmf.mobile.app.dto.response.RepaymentReceiptResponse;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.exception.BusinessException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BatchRepaymentSyncUseCaseTest {

    @Mock
    private CollectRepaymentUseCase collectRepaymentUseCase;

    @InjectMocks
    private BatchRepaymentSyncUseCase batchRepaymentSyncUseCase;

    @Test
    @DisplayName("Đồng bộ mẻ giao dịch offline - 2 thành công và 1 thất bại (bảo toàn dữ liệu từng item)")
    void syncBatchShouldCollectSuccessAndRecordFailedItems() {
        CollectRepaymentRequest req1 = CollectRepaymentRequest.builder()
                .contractCode("HD-001")
                .periodNumber(1)
                .totalAmount(new BigDecimal("50000.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-001")
                .build();

        CollectRepaymentRequest req2 = CollectRepaymentRequest.builder()
                .contractCode("HD-002")
                .periodNumber(1)
                .totalAmount(new BigDecimal("60000.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-002")
                .build();

        CollectRepaymentRequest req3 = CollectRepaymentRequest.builder()
                .contractCode("HD-003")
                .periodNumber(1)
                .totalAmount(new BigDecimal("70000.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-003")
                .build();

        RepaymentReceiptResponse res1 = RepaymentReceiptResponse.builder()
                .transactionId("TX-001")
                .contractCode("HD-001")
                .periodNumber(1)
                .paidAmount(new BigDecimal("50000.00"))
                .status(RepaymentStatus.COLLECTED)
                .build();

        RepaymentReceiptResponse res2 = RepaymentReceiptResponse.builder()
                .transactionId("TX-002")
                .contractCode("HD-002")
                .periodNumber(1)
                .paidAmount(new BigDecimal("60000.00"))
                .status(RepaymentStatus.COLLECTED)
                .build();

        when(collectRepaymentUseCase.collect(eq(req1), eq("USR001"))).thenReturn(res1);
        when(collectRepaymentUseCase.collect(eq(req2), eq("USR001"))).thenReturn(res2);
        when(collectRepaymentUseCase.collect(eq(req3), eq("USR001")))
                .thenThrow(new BusinessException(ErrorCode.ERR_TRANSACTION_ALREADY_SETTLED));

        BatchRepaymentSyncRequest batchRequest = BatchRepaymentSyncRequest.builder()
                .repayments(List.of(req1, req2, req3))
                .build();

        BatchSyncSummaryResponse summary = batchRepaymentSyncUseCase.syncBatch(batchRequest, "USR001");

        assertNotNull(summary);
        assertEquals(3, summary.getTotalSubmitted());
        assertEquals(2, summary.getTotalSuccess());
        assertEquals(1, summary.getTotalFailed());
        assertEquals(new BigDecimal("110000.00"), summary.getTotalAmountProcessed());
        assertEquals(2, summary.getReceipts().size());
        assertEquals(1, summary.getFailedItems().size());
        assertEquals("HD-003", summary.getFailedItems().get(0).getContractCode());
        assertEquals("ERR_TRANSACTION_ALREADY_SETTLED", summary.getFailedItems().get(0).getErrorCode());
    }
}
