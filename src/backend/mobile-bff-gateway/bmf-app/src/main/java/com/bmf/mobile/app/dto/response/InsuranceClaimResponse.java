package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.InsuranceRiskType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Phản hồi chi tiết hồ sơ yêu cầu trợ cấp bảo hiểm tương hỗ.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Thông tin hồ sơ yêu cầu bồi thường bảo hiểm tương hỗ")
public class InsuranceClaimResponse {

    @Schema(description = "Mã hồ sơ yêu cầu bồi thường", example = "CLM-2026-0045")
    private String claimId;

    @Schema(description = "Mã khách hàng", example = "CUST-001")
    private String customerCode;

    @Schema(description = "Mã hợp đồng vay", example = "HD-2026-001")
    private String contractCode;

    @Schema(description = "Loại rủi ro", example = "HEALTH_SICKNESS")
    private InsuranceRiskType riskType;

    @Schema(description = "Số tiền đề nghị trợ cấp (MMK)", example = "30000.00")
    private BigDecimal claimAmount;

    @Schema(description = "Trạng thái hồ sơ", example = "SUBMITTED")
    private InsuranceClaimStatus status;

    @Schema(description = "Thời gian nộp hồ sơ", example = "2026-09-15T12:00:00")
    private LocalDateTime submittedTime;
}
