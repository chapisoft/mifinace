package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Biên lai thu nợ điện tử trả về sau khi gạch nợ thành công (Electronic Receipt).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Biên lai thu nợ điện tử")
public class RepaymentReceiptResponse {

    @Schema(description = "Mã giao dịch gạch nợ duy nhất (UUID)", example = "tx-88392-a9b1c2")
    private String transactionId;

    @Schema(description = "Mã hợp đồng tín dụng", example = "HD-2026-00892")
    private String contractCode;

    @Schema(description = "Mã khách hàng thành viên", example = "CUST-99001")
    private String customerCode;

    @Schema(description = "Tên khách hàng", example = "Daw Khin Myint")
    private String customerName;

    @Schema(description = "Kỳ thu nợ", example = "3")
    private int periodNumber;

    @Schema(description = "Tổng số tiền đã gạch nợ (MMK)", example = "59250.00")
    private BigDecimal paidAmount;

    @Schema(description = "Dư nợ gốc còn lại của hợp đồng (MMK)", example = "450000.00")
    private BigDecimal remainingPrincipal;

    @Schema(description = "Phương thức thanh toán", example = "CASH")
    private RepaymentMethod paymentMethod;

    @Schema(description = "Trạng thái giao dịch", example = "COLLECTED")
    private RepaymentStatus status;

    @Schema(description = "Thời điểm thực hiện thu nợ", example = "2026-09-15T09:30:00")
    private String transactionTime;

    @Schema(description = "Mã cán bộ thực hiện", example = "USR001")
    private String collectedBy;

    @Schema(description = "Khóa chống trùng lặp", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private String idempotencyKey;
}
