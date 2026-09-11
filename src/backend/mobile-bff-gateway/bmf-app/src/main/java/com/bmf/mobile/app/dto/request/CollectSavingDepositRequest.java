package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.RepaymentMethod;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Yêu cầu nộp tiền gửi vào sổ tiết kiệm tại thực địa hoặc qua ví điện tử.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu nộp tiền gửi tiết kiệm")
public class CollectSavingDepositRequest {

    @NotBlank(message = "{validation.saving.accountNumber.required}")
    @Schema(description = "Số tài khoản sổ tiết kiệm", example = "SA-2026-0099")
    private String accountNumber;

    @NotBlank(message = "{validation.saving.customerCode.required}")
    @Schema(description = "Mã khách hàng", example = "CUST-001")
    private String customerCode;

    @NotNull(message = "{validation.saving.amount.required}")
    @DecimalMin(value = "500.00", message = "{validation.saving.amount.min}")
    @Schema(description = "Số tiền nộp gửi tiết kiệm (MMK)", example = "5000.00")
    private BigDecimal amount;

    @NotNull(message = "{validation.saving.paymentMethod.required}")
    @Schema(description = "Phương thức thanh toán", example = "CASH")
    private RepaymentMethod paymentMethod;

    @NotBlank(message = "{validation.loan.idempotencyKey.required}")
    @Schema(description = "Khóa chống trùng lặp Idempotency", example = "IDEM-SAV-20260915-001")
    private String idempotencyKey;

    @Schema(description = "Thời gian thu tiền ngoại tuyến (ISO 8601)", example = "2026-09-15T11:00:00")
    private String offlineTimestamp;
}
