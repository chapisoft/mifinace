package com.bmf.mobile.app.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

/**
 * Phản hồi kết quả xử lý mẻ đồng bộ giao dịch thu nợ offline.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Kết quả đồng bộ mẻ giao dịch offline")
public class BatchSyncSummaryResponse {

    @Schema(description = "Tổng số giao dịch gửi lên", example = "20")
    private int totalSubmitted;

    @Schema(description = "Số giao dịch xử lý thành công", example = "20")
    private int totalSuccess;

    @Schema(description = "Số giao dịch thất bại", example = "0")
    private int totalFailed;

    @Schema(description = "Tổng số tiền đã gạch nợ thành công (MMK)", example = "1185000.00")
    private BigDecimal totalAmountProcessed;

    @Schema(description = "Danh sách chi tiết biên lai gạch nợ thành công")
    private List<RepaymentReceiptResponse> receipts;

    @Schema(description = "Danh sách các giao dịch bị lỗi (nếu có)")
    private List<FailedItem> failedItems;

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FailedItem {
        private String contractCode;
        private int periodNumber;
        private String idempotencyKey;
        private String errorCode;
        private String errorMessage;
    }
}
