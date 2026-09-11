package com.bmf.mobile.app.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Phản hồi chi tiết quyền lợi bảo hiểm tương trợ thành viên BMF.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerInsuranceBenefitResponse {

    private String customerCode;
    private String memberName;
    private String policyNumber;
    private BigDecimal maxHospitalizationBenefit;
    private BigDecimal maxAccidentBenefit;
    private BigDecimal maxLifeBenefit;
    private BigDecimal annualContributionFee;
    private String benefitDescriptionMyanmar;
    private String claimProcedureMyanmar;
    private String emergencyHotline;
}
