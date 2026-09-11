package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingProductType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Phản hồi chi tiết tài khoản sổ tiết kiệm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Thông tin tài khoản sổ tiết kiệm")
public class SavingAccountResponse {

    @Schema(description = "Số tài khoản sổ tiết kiệm", example = "SA-2026-0099")
    private String accountNumber;

    @Schema(description = "Mã khách hàng", example = "CUST-001")
    private String customerCode;

    @Schema(description = "Họ và tên chủ sổ", example = "Daw Khin Myint")
    private String customerName;

    @Schema(description = "Loại sản phẩm tiết kiệm", example = "ACCUMULATIVE")
    private SavingProductType productType;

    @Schema(description = "Số dư gốc hiện tại (MMK)", example = "75000.00")
    private BigDecimal balance;

    @Schema(description = "Lãi suất (% / năm)", example = "10.00")
    private BigDecimal interestRate;

    @Schema(description = "Tiền lãi dồn tích ước tính (MMK)", example = "1250.00")
    private BigDecimal accruedInterest;

    @Schema(description = "Kỳ hạn gửi (tháng)", example = "6")
    private Integer termMonths;

    @Schema(description = "Trạng thái sổ", example = "ACTIVE")
    private SavingAccountStatus status;

    @Schema(description = "Thời gian mở sổ", example = "2026-09-01T08:00:00")
    private LocalDateTime createdTime;
}
