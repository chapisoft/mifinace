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
    private final com.bmf.mobile.domain.repository.RepaymentRepository repaymentRepository;
    private final I18nService i18nService;

    @PostMapping("/mmqr")
    @PreAuthorize("hasAnyRole('AGENT', 'CUSTOMER')")
    @Operation(summary = "TASK-BFF-06.1: Sinh mã MMQR động chuẩn EMVCo CBM kèm ảnh Base64")
    public ResponseEntity<ApiResponse<MmqrResponse>> generateMmqr(@Valid @RequestBody GenerateMmqrRequest request) {
        MmqrResponse response = generateMmqrUseCase.generateMmqr(request);
        String message = i18nService.getMessage("msg.mmqr.generated.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @org.springframework.web.bind.annotation.GetMapping("/{paymentId}/status")
    @PreAuthorize("hasAnyRole('AGENT', 'CUSTOMER')")
    @Operation(summary = "Tra cứu trạng thái xử lý giao dịch thanh toán MMQR")
    public ResponseEntity<ApiResponse<java.util.Map<String, Object>>> getPaymentStatus(
            @org.springframework.web.bind.annotation.PathVariable("paymentId") String paymentId) {
        java.util.Map<String, Object> statusData = new java.util.HashMap<>();
        statusData.put("paymentId", paymentId);
        statusData.put("status", "PENDING");
        statusData.put("settled", false);
        statusData.put("settledAt", null);

        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(statusData, message));
    }

    @org.springframework.web.bind.annotation.GetMapping("/transactions")
    @PreAuthorize("hasAnyRole('AGENT', 'CUSTOMER')")
    @Operation(summary = "Lấy lịch sử giao dịch thanh toán của khách hàng")
    public ResponseEntity<ApiResponse<java.util.List<java.util.Map<String, Object>>>> getTransactions(
            @org.springframework.web.bind.annotation.RequestParam(name = "customerCode", required = false) String customerCode,
            java.security.Principal principal) {
        
        String queryCode = (customerCode != null && !customerCode.isBlank())
                ? customerCode.trim()
                : (principal != null ? principal.getName() : "");

        java.util.List<java.util.Map<String, Object>> result = new java.util.ArrayList<>();
        if (queryCode != null && !queryCode.isBlank()) {
            var dbList = repaymentRepository.findByCustomerCode(queryCode);
            for (var tx : dbList) {
                java.util.Map<String, Object> item = new java.util.HashMap<>();
                item.put("transactionId", tx.getTransactionId());
                item.put("contractCode", tx.getContractCode());
                item.put("periodNumber", tx.getPeriodNumber());
                item.put("principalAmountMmk", tx.getPrincipalAmount());
                item.put("interestAmountMmk", tx.getInterestAmount());
                item.put("insuranceFeeMmk", tx.getInsuranceFee());
                item.put("compulsorySavingMmk", tx.getCompulsorySaving());
                item.put("totalAmountMmk", tx.getTotalAmount());
                item.put("paymentMethod", tx.getPaymentMethod() != null ? tx.getPaymentMethod().name() : "CASH");
                item.put("status", tx.getStatus() != null ? tx.getStatus().name() : "SETTLED");
                item.put("transactionTime", tx.getCollectedTime() != null ? tx.getCollectedTime().toString() : java.time.LocalDateTime.now().toString());
                item.put("category", "REPAYMENT");
                item.put("notes", tx.getNotes());
                result.add(item);
            }
        }

        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(result, message));
    }
}
