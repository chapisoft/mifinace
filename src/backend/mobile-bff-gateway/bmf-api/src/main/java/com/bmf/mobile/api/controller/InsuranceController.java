package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.SubmitInsuranceClaimRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.InsuranceClaimResponse;
import com.bmf.mobile.app.service.I18nService;
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
import java.util.List;

/**
 * Controller quản lý hồ sơ yêu cầu trợ cấp bảo hiểm tương hỗ.
 */
@RestController
@RequestMapping("/api/v1/insurance")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "06. Micro Mutual Insurance", description = "Tiếp nhận và tra cứu hồ sơ trợ cấp bảo hiểm tương hỗ thành viên")
public class InsuranceController {

    private final SubmitInsuranceClaimUseCase submitInsuranceClaimUseCase;
    private final I18nService i18nService;

    @PostMapping("/claim")
    @PreAuthorize("hasAnyRole('AGENT', 'CUSTOMER')")
    @Operation(summary = "Nộp hồ sơ yêu cầu trợ cấp bảo hiểm tương hỗ y tế/tai nạn/rủi ro")
    public ResponseEntity<ApiResponse<InsuranceClaimResponse>> submitClaim(
            @Valid @RequestBody SubmitInsuranceClaimRequest request,
            Principal principal) {

        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String submittedBy = principal.getName();
        InsuranceClaimResponse response = submitInsuranceClaimUseCase.submitClaim(request, submittedBy);
        String message = i18nService.getMessage("msg.insurance.submitted");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @GetMapping("/my-claims")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Khách hàng tra cứu tiến độ xử lý hồ sơ yêu cầu bồi thường bảo hiểm")
    public ResponseEntity<ApiResponse<List<InsuranceClaimResponse>>> getMyClaims(
            Principal principal) {

        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String customerCode = principal.getName();
        List<InsuranceClaimResponse> claims = submitInsuranceClaimUseCase.getMyClaims(customerCode);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(claims, message));
    }
}
