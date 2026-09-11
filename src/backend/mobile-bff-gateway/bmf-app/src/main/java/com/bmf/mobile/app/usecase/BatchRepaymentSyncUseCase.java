package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.BatchRepaymentSyncRequest;
import com.bmf.mobile.app.dto.request.CollectRepaymentRequest;
import com.bmf.mobile.app.dto.response.BatchSyncSummaryResponse;
import com.bmf.mobile.app.dto.response.RepaymentReceiptResponse;
import com.bmf.mobile.domain.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * UseCase xử lý mẻ đồng bộ danh sách các giao dịch thu nợ ngoại tuyến (Offline Batch Sync).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BatchRepaymentSyncUseCase {

    private final CollectRepaymentUseCase collectRepaymentUseCase;

    public BatchSyncSummaryResponse syncBatch(BatchRepaymentSyncRequest request, String collectedByUserId) {
        log.info("Starting batch repayment sync: totalItems={}, collectedBy={}",
                request.getRepayments().size(), collectedByUserId);

        List<RepaymentReceiptResponse> successReceipts = new ArrayList<>();
        List<BatchSyncSummaryResponse.FailedItem> failedItems = new ArrayList<>();
        BigDecimal totalAmountProcessed = BigDecimal.ZERO;

        for (CollectRepaymentRequest singleRequest : request.getRepayments()) {
            try {
                RepaymentReceiptResponse receipt = collectRepaymentUseCase.collect(singleRequest, collectedByUserId);
                successReceipts.add(receipt);
                if (receipt.getPaidAmount() != null) {
                    totalAmountProcessed = totalAmountProcessed.add(receipt.getPaidAmount());
                }
            } catch (BusinessException be) {
                log.warn("Failed to sync repayment item in batch: contract={}, period={}, errorCode={}",
                        singleRequest.getContractCode(), singleRequest.getPeriodNumber(), be.getErrorCode());

                failedItems.add(BatchSyncSummaryResponse.FailedItem.builder()
                        .contractCode(singleRequest.getContractCode())
                        .periodNumber(singleRequest.getPeriodNumber())
                        .idempotencyKey(singleRequest.getIdempotencyKey())
                        .errorCode(be.getErrorCode().getCode())
                        .errorMessage(be.getMessage())
                        .build());
            } catch (Exception e) {
                log.error("Unexpected error syncing repayment item in batch: contract={}, period={}",
                        singleRequest.getContractCode(), singleRequest.getPeriodNumber(), e);

                failedItems.add(BatchSyncSummaryResponse.FailedItem.builder()
                        .contractCode(singleRequest.getContractCode())
                        .periodNumber(singleRequest.getPeriodNumber())
                        .idempotencyKey(singleRequest.getIdempotencyKey())
                        .errorCode("ERR_INTERNAL_SERVER")
                        .errorMessage(e.getMessage())
                        .build());
            }
        }

        log.info("Batch repayment sync completed: total={}, success={}, failed={}, amount={}",
                request.getRepayments().size(), successReceipts.size(), failedItems.size(), totalAmountProcessed);

        return BatchSyncSummaryResponse.builder()
                .totalSubmitted(request.getRepayments().size())
                .totalSuccess(successReceipts.size())
                .totalFailed(failedItems.size())
                .totalAmountProcessed(totalAmountProcessed)
                .receipts(successReceipts)
                .failedItems(failedItems)
                .build();
    }
}
