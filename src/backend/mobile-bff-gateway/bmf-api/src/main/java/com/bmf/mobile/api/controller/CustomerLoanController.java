package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanScheduleResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanSummaryResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.CustomerLoanQueryUseCase;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

/**
 * Controller dành riêng cho Khách hàng thành viên tra cứu hợp đồng tín dụng và lịch trả nợ 5 nhóm nợ FRD Myanmar.
 */
@RestController
@RequestMapping("/api/v1/customer/loans")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "08. Customer Loans & FRD Debt Schedules", description = "Khách hàng tra cứu hợp đồng tín dụng, lịch trả nợ toàn khóa và phân loại 5 nhóm nợ FRD Myanmar")
public class CustomerLoanController {

    private final CustomerLoanQueryUseCase customerLoanQueryUseCase;
    private final I18nService i18nService;

    @GetMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "TASK-BFF-05.8: Khách hàng tra cứu danh sách khoản vay và tổng dư nợ")
    public ResponseEntity<ApiResponse<CustomerLoanSummaryResponse>> getCustomerLoans(Principal principal) {
        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String customerCode = principal.getName();
        CustomerLoanSummaryResponse response = customerLoanQueryUseCase.getLoanSummary(customerCode);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @GetMapping("/{loanId}/schedule")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "TASK-BFF-05.9: Khách hàng tra cứu chi tiết lịch trả nợ toàn khóa kèm 5 nhóm nợ chuẩn FRD")
    public ResponseEntity<ApiResponse<CustomerLoanScheduleResponse>> getLoanScheduleDetail(
            @PathVariable("loanId") String loanId,
            Principal principal) {

        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new com.bmf.mobile.domain.exception.BusinessException(com.bmf.mobile.domain.enums.ErrorCode.ERR_UNAUTHORIZED);
        }
        String customerCode = principal.getName();
        CustomerLoanScheduleResponse response = customerLoanQueryUseCase.getLoanScheduleDetail(customerCode, loanId);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }
}
