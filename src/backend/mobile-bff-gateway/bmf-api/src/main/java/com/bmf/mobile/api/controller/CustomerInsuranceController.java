package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.SubmitInsuranceClaimRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.CustomerInsuranceBenefitResponse;
import com.bmf.mobile.app.dto.response.InsuranceClaimResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.CustomerBenefitQueryUseCase;
import com.bmf.mobile.app.usecase.SubmitInsuranceClaimUseCase;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

/**
 * Controller dành riêng cho Khách hàng tra cứu quyền lợi bảo hiểm tương trợ và nộp hồ sơ trợ cấp y tế trực tuyến.
 */
@RestController
@RequestMapping("/api/v1/customer/insurance")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "10. Customer Insurance & Welfare Claims", description = "Khách hàng tra cứu quyền lợi bảo hiểm tương hỗ và nộp hồ sơ trợ cấp viện phí kèm chứng từ số hóa")
public class CustomerInsuranceController {

    private final CustomerBenefitQueryUseCase customerBenefitQueryUseCase;
    private final SubmitInsuranceClaimUseCase submitInsuranceClaimUseCase;
    private final I18nService i18nService;

    @GetMapping("/benefits")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Khách hàng tra cứu bảng quyền lợi bảo hiểm tương hỗ")
    public ResponseEntity<ApiResponse<CustomerInsuranceBenefitResponse>> getBenefits(Principal principal) {
        String customerCode = principal != null ? principal.getName() : "CUST-DEFAULT";
        CustomerInsuranceBenefitResponse response = customerBenefitQueryUseCase.getInsuranceBenefits(customerCode);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/claim")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "TASK-BFF-05.12: Khách hàng tự nộp hồ sơ yêu cầu trợ cấp bảo hiểm đính kèm ảnh")
    public ResponseEntity<ApiResponse<InsuranceClaimResponse>> submitClaimOnline(
            @Valid @RequestBody SubmitInsuranceClaimRequest request,
            Principal principal) {

        String customerCode = principal != null ? principal.getName() : "CUST-DEFAULT";
        request.setCustomerCode(customerCode);
        InsuranceClaimResponse response = submitInsuranceClaimUseCase.submitClaim(request, customerCode);
        String message = i18nService.getMessage("msg.insurance.claim.submitted");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }
}
