package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.ConfirmCashHandoverRequest;
import com.bmf.mobile.app.dto.request.GenerateCashHandoverQrRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.CashHandoverQrResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.CashHandoverUseCase;
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
 * Controller quản lý quy trình đối soát và bàn giao quỹ tiền mặt lưu động cuối ngày.
 */
@RestController
@RequestMapping("/api/v1/cash")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "07. Cash Handover & Floating Fund Management", description = "Quản lý quỹ tiền mặt lưu động, sinh mã QR đối soát và xác nhận nhập quỹ")
public class CashHandoverController {

    private final CashHandoverUseCase cashHandoverUseCase;
    private final I18nService i18nService;

    @PostMapping("/handover-qr")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Cán bộ tín dụng sinh mã QR bảo mật bàn giao quỹ tiền mặt cuối ngày")
    public ResponseEntity<ApiResponse<CashHandoverQrResponse>> generateHandoverQr(
            @RequestBody(required = false) GenerateCashHandoverQrRequest request,
            Principal principal) {

        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String collectorId = principal.getName();
        CashHandoverQrResponse response = cashHandoverUseCase.generateHandoverQr(request, collectorId);
        String message = i18nService.getMessage("msg.handover.qr.generated");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/handover/confirm")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Thủ quỹ tại chi nhánh quét mã QR và xác nhận nhập quỹ tiền mặt")
    public ResponseEntity<ApiResponse<Void>> confirmHandover(
            @Valid @RequestBody ConfirmCashHandoverRequest request,
            Principal principal) {

        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String cashierId = principal.getName();
        cashHandoverUseCase.confirmHandover(request, cashierId);
        String message = i18nService.getMessage("msg.handover.confirmed");
        return ResponseEntity.ok(ApiResponse.ok(null, message));
    }
}
