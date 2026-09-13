package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.response.CustomerInsuranceBenefitResponse;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * UseCase tra cứu quyền lợi bảo hiểm tương hỗ thành viên BMF.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerBenefitQueryUseCase {

    private final CustomerRepository customerRepository;

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.max-hospitalization-benefit:200000.00}")
    private BigDecimal maxHospitalizationBenefit = new BigDecimal("200000.00");

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.max-accident-benefit:500000.00}")
    private BigDecimal maxAccidentBenefit = new BigDecimal("500000.00");

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.max-life-benefit:1000000.00}")
    private BigDecimal maxLifeBenefit = new BigDecimal("1000000.00");

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.annual-contribution-fee:12000.00}")
    private BigDecimal annualContributionFee = new BigDecimal("12000.00");

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.emergency-hotline:+95 1 234 5678}")
    private String emergencyHotline = "+95 1 234 5678";

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.benefit-description-myanmar:BMF အဖွဲ့ဝင်များအတွက် ဆေးရုံတက်စရိတ်နှင့် မတော်တဆမှု အထောက်အပံ့ ရန်ပုံငွေ အကျိုးခံစားခွင့်များ}")
    private String benefitDescriptionMyanmar = "BMF အဖွဲ့ဝင်များအတွက် ဆေးရုံတက်စရိတ်နှင့် မတော်တဆမှု အထောက်အပံ့ ရန်ပုံငွေ အကျိုးခံစားခွင့်များ";

    @org.springframework.beans.factory.annotation.Value("${bmf.insurance.claim-procedure-myanmar:ဆေးရုံဆေးခန်း အထောက်အထားစာရွက်စာတမ်းများနှင့် ရပ်ကျေးထောက်ခံစာ တင်ပြလျှောက်ထားနိုင်ပါသည်}")
    private String claimProcedureMyanmar = "ဆေးရုံဆေးခန်း အထောက်အထားစာရွက်စာတမ်းများနှင့် ရပ်ကျေးထောက်ခံစာ တင်ပြလျှောက်ထားနိုင်ပါသည်";

    public CustomerInsuranceBenefitResponse getInsuranceBenefits(String customerCode) {
        log.info("Processing customer insurance benefit query: customerCode={}", customerCode);

        CustomerMember customer = customerRepository.findByCustomerCode(customerCode)
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_USER_NOT_FOUND));

        String policyNumber = "POL-BMF-" + customer.getCustomerCode();

        return CustomerInsuranceBenefitResponse.builder()
                .customerCode(customer.getCustomerCode())
                .memberName(customer.getFullName())
                .policyNumber(policyNumber)
                .maxHospitalizationBenefit(maxHospitalizationBenefit)
                .maxAccidentBenefit(maxAccidentBenefit)
                .maxLifeBenefit(maxLifeBenefit)
                .annualContributionFee(annualContributionFee)
                .benefitDescriptionMyanmar(benefitDescriptionMyanmar)
                .claimProcedureMyanmar(claimProcedureMyanmar)
                .emergencyHotline(emergencyHotline)
                .build();
    }
}
