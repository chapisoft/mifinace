package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.CashHandoverStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Phản hồi mã QR và thông tin bàn giao quỹ tiền mặt để thủ quỹ quét đối soát.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Mã QR và thông tin bàn giao quỹ tiền mặt")
public class CashHandoverQrResponse {

    @Schema(description = "Mã biên bản bàn giao quỹ", example = "HO-20260915-USR001")
    private String handoverId;

    @Schema(description = "Mã cán bộ thu nợ", example = "USR001")
    private String collectorId;

    @Schema(description = "Ngày bàn giao", example = "2026-09-15")
    private LocalDate handoverDate;

    @Schema(description = "Tổng số tiền mặt đã thu trong ngày (MMK)", example = "1250000.00")
    private BigDecimal totalAmount;

    @Schema(description = "Tổng số lượng phiếu thu đã lập trong ngày", example = "25")
    private Integer totalTransactions;

    @Schema(description = "Chuỗi mã hóa QR bảo mật kèm chữ ký số HMAC-SHA256", example = "BMF_HANDOVER:HO-20260915-USR001|1250000.00|25|SIG_a8b9c0...")
    private String qrPayload;

    @Schema(description = "Trạng thái bàn giao", example = "PENDING_CONFIRMATION")
    private CashHandoverStatus status;
}
