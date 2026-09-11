package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.enums.SavingTransactionType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Biên lai điện tử xác nhận giao dịch nộp tiền tiết kiệm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Biên nhận giao dịch nộp tiền tiết kiệm")
public class SavingTransactionReceiptResponse {

    @Schema(description = "Mã giao dịch duy nhất", example = "TX-SAV-20260915-0012")
    private String transactionId;

    @Schema(description = "Số tài khoản sổ tiết kiệm", example = "SA-2026-0099")
    private String accountNumber;

    @Schema(description = "Mã khách hàng", example = "CUST-001")
    private String customerCode;

    @Schema(description = "Số tiền đã nộp (MMK)", example = "5000.00")
    private BigDecimal amount;

    @Schema(description = "Số dư sau giao dịch (MMK)", example = "80000.00")
    private BigDecimal newBalance;

    @Schema(description = "Loại giao dịch", example = "DEPOSIT")
    private SavingTransactionType transactionType;

    @Schema(description = "Phương thức thanh toán", example = "CASH")
    private RepaymentMethod paymentMethod;

    @Schema(description = "Trạng thái giao dịch", example = "COLLECTED")
    private RepaymentStatus status;

    @Schema(description = "Thời gian ghi nhận giao dịch", example = "2026-09-15T11:00:00")
    private LocalDateTime transactionTime;
}
