package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.InsuranceRiskType;
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
 * Yêu cầu nộp hồ sơ yêu cầu trợ cấp bảo hiểm tương hỗ.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu nộp hồ sơ trợ cấp bảo hiểm tương hỗ")
public class SubmitInsuranceClaimRequest {

    @NotBlank(message = "{validation.insurance.customerCode.required}")
    @Schema(description = "Mã khách hàng / thành viên", example = "CUST-001")
    private String customerCode;

    @Schema(description = "Mã hợp đồng tín dụng liên kết", example = "HD-2026-001")
    private String contractCode;

    @NotNull(message = "{validation.insurance.riskType.required}")
    @Schema(description = "Loại sự cố rủi ro", example = "HEALTH_SICKNESS")
    private InsuranceRiskType riskType;

    @NotNull(message = "{validation.insurance.claimAmount.required}")
    @DecimalMin(value = "1000.00", message = "{validation.insurance.claimAmount.min}")
    @Schema(description = "Số tiền yêu cầu trợ cấp (MMK)", example = "30000.00")
    private BigDecimal claimAmount;

    @Schema(description = "Mô tả chi tiết sự cố rủi ro", example = "Nằm viện điều trị sốt rét 5 ngày tại bệnh viện Township")
    private String description;

    @Schema(description = "Danh sách URL ảnh hóa đơn/chứng từ y tế phân tách bởi dấu phẩy", example = "https://storage.bmf.mm/docs/med_01.jpg,https://storage.bmf.mm/docs/med_02.jpg")
    private String medicalDocUrls;

    @Schema(description = "URL ảnh xác nhận của Trưởng làng / Chính quyền địa phương", example = "https://storage.bmf.mm/docs/village_head_01.jpg")
    private String villageHeadDocUrl;
}
