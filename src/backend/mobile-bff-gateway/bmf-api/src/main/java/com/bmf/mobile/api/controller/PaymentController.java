package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.GenerateMmqrRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.MmqrResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.GenerateMmqrUseCase;
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

/**
 * Controller sinh mã thanh toán MMQR chuẩn EMVCo CBM (Central Bank of Myanmar).
 */
@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "11. Digital Payments & MMQR Engine", description = "Sinh mã MMQR động EMVCo CBM cho từng kỳ nợ và tích hợp liên thông ví điện tử")
public class PaymentController {

    private final GenerateMmqrUseCase generateMmqrUseCase;
    private final I18nService i18nService;

    @PostMapping("/mmqr")
    @PreAuthorize("hasAnyRole('AGENT', 'CUSTOMER')")
    @Operation(summary = "TASK-BFF-06.1: Sinh mã MMQR động chuẩn EMVCo CBM kèm ảnh Base64")
    public ResponseEntity<ApiResponse<MmqrResponse>> generateMmqr(@Valid @RequestBody GenerateMmqrRequest request) {
        MmqrResponse response = generateMmqrUseCase.generateMmqr(request);
        String message = i18nService.getMessage("msg.mmqr.generated.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }
}
