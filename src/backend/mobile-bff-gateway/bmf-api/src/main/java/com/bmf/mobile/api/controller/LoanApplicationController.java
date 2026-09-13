package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.ApplyLoanRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.LoanApplicationResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.ApplyLoanUseCase;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

/**
 * Controller quản lý quy trình nộp hồ sơ vay vốn thực địa và thẩm định tín dụng.
 */
@RestController
@RequestMapping("/api/v1/loans")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "04. Loan Application & Credit Scoring", description = "Nộp hồ sơ vay vốn, khảo sát GPS, OCR thẻ NRC và thẩm định tín dụng")
public class LoanApplicationController {

    private final ApplyLoanUseCase applyLoanUseCase;
    private final I18nService i18nService;

    @PostMapping("/apply")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Cán bộ tín dụng nộp hồ sơ vay vốn và thẩm định thực địa")
    public ResponseEntity<ApiResponse<LoanApplicationResponse>> applyLoan(
            @Valid @RequestBody ApplyLoanRequest request,
            Principal principal) {

        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String createdBy = principal.getName();
        LoanApplicationResponse response = applyLoanUseCase.apply(request, createdBy);
        String message = i18nService.getMessage("msg.loan.apply.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }
}
