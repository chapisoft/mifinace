package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.SavingProductType;
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
 * Yêu cầu mở sổ tiết kiệm tại chỗ hoặc trực tuyến.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu mở sổ tiết kiệm tài chính vi mô")
public class OpenSavingAccountRequest {

    @NotBlank(message = "{validation.saving.customerCode.required}")
    @Schema(description = "Mã khách hàng", example = "CUST-001")
    private String customerCode;

    @NotBlank(message = "{validation.saving.customerName.required}")
    @Schema(description = "Họ và tên khách hàng", example = "Daw Khin Myint")
    private String customerName;

    @NotNull(message = "{validation.saving.productType.required}")
    @Schema(description = "Loại sản phẩm tiết kiệm", example = "ACCUMULATIVE")
    private SavingProductType productType;

    @NotNull(message = "{validation.saving.initialDeposit.required}")
    @DecimalMin(value = "1000.00", message = "{validation.saving.initialDeposit.min}")
    @Schema(description = "Số tiền gửi ban đầu (MMK)", example = "10000.00")
    private BigDecimal initialDeposit;

    @Schema(description = "Kỳ hạn gửi (tháng)", example = "6")
    private Integer termMonths;

    @Schema(description = "Họ và tên người thụ hưởng / thừa kế", example = "U Aung Myo")
    private String beneficiaryName;

    @Schema(description = "Số thẻ NRC người thụ hưởng", example = "12/DAGAMA(N)098765")
    private String beneficiaryNrc;
}
