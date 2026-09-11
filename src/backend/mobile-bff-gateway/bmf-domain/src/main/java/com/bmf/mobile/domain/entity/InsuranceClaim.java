package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.InsuranceRiskType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Thực thể hồ sơ yêu cầu trợ cấp bảo hiểm tương hỗ.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InsuranceClaim {
    private String claimId;
    private String customerCode;
    private String contractCode;
    private InsuranceRiskType riskType;
    private BigDecimal claimAmount;
    private String medicalDocUrls;
    private String villageHeadDocUrl;
    private String description;
    private InsuranceClaimStatus status;
    private String submittedBy;
    private LocalDateTime submittedTime;
    private LocalDateTime approvedTime;
    private String approvedBy;
}
