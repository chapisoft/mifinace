package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.RepaymentMethod;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Yêu cầu gạch nợ tín dụng vi mô (Thu tiền tại thực địa hoặc trực tuyến).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu gạch nợ tín dụng vi mô")
public class CollectRepaymentRequest {

    @NotBlank(message = "{validation.loan.contractCode.notBlank}")
    @Size(max = 64, message = "{validation.loan.contractCode.size}")
    @Schema(description = "Mã hợp đồng vay vốn", example = "HD-2026-00892")
    private String contractCode;

    @NotBlank(message = "{validation.loan.customerCode.notBlank}")
    @Size(max = 32, message = "{validation.loan.customerCode.size}")
    @Schema(description = "Mã khách hàng thành viên", example = "CUST-99001")
    private String customerCode;

    @Min(value = 1, message = "{validation.loan.periodNumber.min}")
    @Schema(description = "Kỳ thu nợ", example = "3")
    private int periodNumber;

    @Schema(description = "Số tiền gốc kỳ này (MMK)", example = "50000.00")
    private BigDecimal principalAmount;

    @Schema(description = "Số tiền lãi kỳ này (MMK)", example = "6250.00")
    private BigDecimal interestAmount;

    @Schema(description = "Phí bảo hiểm vi mô (MMK)", example = "1000.00")
    private BigDecimal insuranceFee;

    @Schema(description = "Tiết kiệm bắt buộc (MMK)", example = "2000.00")
    private BigDecimal compulsorySaving;

    @Schema(description = "Tiền phạt quá hạn (nếu có)", example = "0.00")
    private BigDecimal penaltyAmount;

    @NotNull(message = "{validation.loan.totalAmount.notNull}")
    @DecimalMin(value = "0.01", message = "{validation.loan.totalAmount.min}")
    @Schema(description = "Tổng số tiền thu thực tế", example = "59250.00")
    private BigDecimal totalAmount;

    @NotNull(message = "{validation.loan.paymentMethod.notNull}")
    @Schema(description = "Phương thức thanh toán", example = "CASH")
    private RepaymentMethod paymentMethod;

    @NotBlank(message = "{validation.loan.idempotencyKey.notBlank}")
    @Size(max = 64, message = "{validation.loan.idempotencyKey.size}")
    @Schema(description = "Khóa chống trùng lặp giao dịch (UUID sinh từ Mobile Client)", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private String idempotencyKey;

    @Schema(description = "Thời điểm cán bộ thu tiền thực tế tại bản làng (định dạng ISO-8601)", example = "2026-09-15T09:30:00")
    private String offlineTimestamp;

    @Size(max = 255, message = "{validation.loan.notes.size}")
    @Schema(description = "Ghi chú thu tiền", example = "Thu tien mat tai cuoc hop to")
    private String notes;
}
