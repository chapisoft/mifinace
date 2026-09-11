package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.OpenSavingAccountRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.CustomerSavingOverviewResponse;
import com.bmf.mobile.app.dto.response.SavingAccountResponse;
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

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;

/**
 * Controller dành riêng cho Khách hàng quản lý sổ tiết kiệm và lãi dồn tích thực tế hàng ngày MMK.
 */
@RestController
@RequestMapping("/api/v1/customer/savings")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "09. Customer Savings & Deposit Portfolio", description = "Khách hàng tra cứu sổ tiết kiệm, lãi dồn tích thực tế và mở sổ tích lũy online")
public class CustomerSavingController {

    private final ManageSavingsUseCase manageSavingsUseCase;
    private final I18nService i18nService;

    @GetMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "TASK-BFF-05.10: Khách hàng tra cứu danh sách sổ tiết kiệm và tổng lãi dồn tích thực tế")
    public ResponseEntity<ApiResponse<CustomerSavingOverviewResponse>> getCustomerSavings(Principal principal) {
        String customerCode = principal != null ? principal.getName() : "CUST-DEFAULT";
        List<SavingAccountResponse> accounts = manageSavingsUseCase.getMySavingAccounts(customerCode);

        BigDecimal totalBalance = accounts.stream()
                .map(a -> a.getBalance() != null ? a.getBalance() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalAccruedInterest = accounts.stream()
                .map(a -> a.getAccruedInterest() != null ? a.getAccruedInterest() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        CustomerSavingOverviewResponse overview = CustomerSavingOverviewResponse.builder()
                .customerCode(customerCode)
                .totalSavingsBalance(totalBalance)
                .totalAccruedInterest(totalAccruedInterest)
                .totalAccounts(accounts.size())
                .accounts(accounts)
                .build();

        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(overview, message));
    }

    @PostMapping("/open")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "TASK-BFF-05.11: Khách hàng mở sổ tiết kiệm tích lũy trực tuyến")
    public ResponseEntity<ApiResponse<SavingAccountResponse>> openSavingOnline(
            @Valid @RequestBody OpenSavingAccountRequest request,
            Principal principal) {

        String customerCode = principal != null ? principal.getName() : "CUST-DEFAULT";
        request.setCustomerCode(customerCode);
        SavingAccountResponse response = manageSavingsUseCase.openAccount(request, customerCode);
        String message = i18nService.getMessage("msg.saving.open.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }
}
