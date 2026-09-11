package com.bmf.mobile.app.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Yêu cầu nộp hồ sơ vay vốn thực địa kèm thông tin thẩm định và tọa độ GPS.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu nộp hồ sơ vay vốn thực địa và thẩm định tín dụng")
public class ApplyLoanRequest {

    @NotBlank(message = "{validation.loan.customerCode.required}")
    @Schema(description = "Mã khách hàng / thành viên", example = "CUST-001")
    private String customerCode;

    @NotBlank(message = "{validation.loan.customerName.required}")
    @Schema(description = "Họ và tên khách hàng", example = "Daw Khin Myint")
    private String customerName;

    @NotBlank(message = "{validation.loan.nrcNumber.required}")
    @Schema(description = "Số căn cước công dân NRC Myanmar", example = "12/DAGAMA(N)045612")
    private String nrcNumber;

    @NotBlank(message = "{validation.loan.groupCode.required}")
    @Schema(description = "Mã Cụm/Tổ sinh hoạt", example = "GRP-YGN-01")
    private String groupCode;

    @NotBlank(message = "{validation.loan.productCode.required}")
    @Schema(description = "Mã gói sản phẩm vay vốn", example = "MICRO_BIZ_01")
    private String loanProductCode;

    @NotNull(message = "{validation.loan.amount.required}")
    @DecimalMin(value = "10000.00", message = "{validation.loan.amount.min}")
    @Schema(description = "Số tiền đề nghị vay (MMK)", example = "500000.00")
    private BigDecimal requestedAmount;

    @NotNull(message = "{validation.loan.term.required}")
    @Min(value = 1, message = "{validation.loan.term.min}")
    @Schema(description = "Kỳ hạn vay (tháng)", example = "12")
    private Integer termMonths;

    @Schema(description = "Mục đích sử dụng vốn vay", example = "Mở rộng sạp hàng tạp hóa buôn làng")
    private String purpose;

    @Schema(description = "Tọa độ GPS Vĩ độ (Latitude)", example = "16.8660694")
    private BigDecimal gpsLatitude;

    @Schema(description = "Tọa độ GPS Kinh độ (Longitude)", example = "96.1951234")
    private BigDecimal gpsLongitude;

    @Schema(description = "URL ảnh mặt trước thẻ NRC", example = "https://storage.bmf.mm/docs/nrc_f_001.jpg")
    private String nrcFrontImageUrl;

    @Schema(description = "URL ảnh mặt sau thẻ NRC", example = "https://storage.bmf.mm/docs/nrc_b_001.jpg")
    private String nrcBackImageUrl;

    @Schema(description = "URL ảnh khảo sát thực địa hiện trạng nhà ở", example = "https://storage.bmf.mm/docs/survey_001.jpg")
    private String surveyImageUrl;

    @Schema(description = "URL ảnh chữ ký số điện tử của khách hàng", example = "https://storage.bmf.mm/docs/sign_001.png")
    private String signatureImageUrl;
}
