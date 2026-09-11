package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.CollectSavingDepositRequest;
import com.bmf.mobile.app.dto.request.OpenSavingAccountRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.SavingAccountResponse;
import com.bmf.mobile.app.dto.response.SavingTransactionReceiptResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.ManageSavingsUseCase;
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
 * Controller quản lý sổ tiết kiệm: Mở sổ, Nộp tiền gửi và Tra cứu số dư lãi tích lũy.
 */
@RestController
@RequestMapping("/api/v1/savings")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "05. Savings & Deposit Management", description = "Mở sổ tiết kiệm, nộp tiền gửi tại buôn làng và tra cứu lãi tích lũy")
public class SavingController {

    private final ManageSavingsUseCase manageSavingsUseCase;
    private final I18nService i18nService;

    @PostMapping("/open")
    @PreAuthorize("hasAnyRole('AGENT', 'CUSTOMER')")
    @Operation(summary = "Mở sổ tiết kiệm vi mô mới (Cán bộ hoặc Khách hàng)")
    public ResponseEntity<ApiResponse<SavingAccountResponse>> openAccount(
            @Valid @RequestBody OpenSavingAccountRequest request,
            Principal principal) {

        String createdBy = principal != null ? principal.getName() : "SYSTEM";
        SavingAccountResponse response = manageSavingsUseCase.openAccount(request, createdBy);
        String message = i18nService.getMessage("msg.saving.open.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/collect")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Thu tiền nộp gửi tiết kiệm tại thực địa buôn làng (Cán bộ tín dụng)")
    public ResponseEntity<ApiResponse<SavingTransactionReceiptResponse>> collectDeposit(
            @Valid @RequestBody CollectSavingDepositRequest request,
            Principal principal) {

        String collectedBy = principal != null ? principal.getName() : "SYSTEM";
        SavingTransactionReceiptResponse receipt = manageSavingsUseCase.collectDeposit(request, collectedBy);
        String message = i18nService.getMessage("msg.saving.collected");
        return ResponseEntity.ok(ApiResponse.ok(receipt, message));
    }

    @GetMapping("/my-accounts")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Khách hàng tra cứu danh sách sổ tiết kiệm và lãi dồn tích")
    public ResponseEntity<ApiResponse<List<SavingAccountResponse>>> getMyAccounts(
            Principal principal) {

        String customerCode = principal != null ? principal.getName() : "SYSTEM";
        List<SavingAccountResponse> accounts = manageSavingsUseCase.getMySavingAccounts(customerCode);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(accounts, message));
    }
}
