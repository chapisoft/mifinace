package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.BatchRepaymentSyncRequest;
import com.bmf.mobile.app.dto.request.CollectRepaymentRequest;
import com.bmf.mobile.app.dto.request.SyncScheduleRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.BatchSyncSummaryResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanSummaryResponse;
import com.bmf.mobile.app.dto.response.RepaymentReceiptResponse;
import com.bmf.mobile.app.dto.response.ScheduleSyncResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.BatchRepaymentSyncUseCase;
import com.bmf.mobile.app.usecase.CollectRepaymentUseCase;
import com.bmf.mobile.app.usecase.CustomerLoanQueryUseCase;
import com.bmf.mobile.app.usecase.SyncRepaymentScheduleUseCase;
import com.bmf.mobile.infra.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller quản lý toàn bộ quy trình thu nợ tín dụng vi mô, đồng bộ offline và tra cứu dư nợ.
 */
@RestController
@RequestMapping("/api/v1/loans")
@RequiredArgsConstructor
@SecurityRequirement(name = "BearerAuth")
@Tag(name = "03. Loan Repayment & Offline Sync Engine", description = "Đồng bộ lịch thu nợ, gạch nợ tín dụng trực tuyến/ngoại tuyến và tra cứu dư nợ")
public class RepaymentController {

    private final SyncRepaymentScheduleUseCase syncRepaymentScheduleUseCase;
    private final CollectRepaymentUseCase collectRepaymentUseCase;
    private final BatchRepaymentSyncUseCase batchRepaymentSyncUseCase;
    private final CustomerLoanQueryUseCase customerLoanQueryUseCase;
    private final I18nService i18nService;

    @GetMapping("/schedules/sync")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Đồng bộ lịch thu nợ Cụm/Tổ (Cán bộ tín dụng)")
    public ResponseEntity<ApiResponse<ScheduleSyncResponse>> syncSchedule(
            @RequestParam("groupCode") String groupCode,
            @RequestParam(value = "dueDate", required = false) String dueDate) {

        SyncScheduleRequest request = SyncScheduleRequest.builder()
                .groupCode(groupCode)
                .dueDate(dueDate)
                .build();

        ScheduleSyncResponse response = syncRepaymentScheduleUseCase.syncSchedule(request);
        String message = i18nService.getMessage("msg.schedule.sync.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/repayments/collect")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Gạch nợ tín dụng trực tuyến hoặc ngoại tuyến đơn lẻ (Cán bộ tín dụng)")
    public ResponseEntity<ApiResponse<RepaymentReceiptResponse>> collectRepayment(
            @Valid @RequestBody CollectRepaymentRequest request,
            java.security.Principal principal) {

        String collectedBy = principal != null ? principal.getName() : "SYSTEM";
        RepaymentReceiptResponse receipt = collectRepaymentUseCase.collect(request, collectedBy);
        String message = i18nService.getMessage("msg.repayment.collected");
        return ResponseEntity.ok(ApiResponse.ok(receipt, message));
    }

    @PostMapping("/repayments/batch-sync")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Đồng bộ mẻ các khoản thu tiền ngoại tuyến (Cán bộ tín dụng)")
    public ResponseEntity<ApiResponse<BatchSyncSummaryResponse>> batchSyncRepayments(
            @Valid @RequestBody BatchRepaymentSyncRequest request,
            java.security.Principal principal) {

        String collectedBy = principal != null ? principal.getName() : "SYSTEM";
        BatchSyncSummaryResponse summary = batchRepaymentSyncUseCase.syncBatch(request, collectedBy);
        String message = i18nService.getMessage("msg.repayment.sync.success");
        return ResponseEntity.ok(ApiResponse.ok(summary, message));
    }

    @GetMapping("/my-loans")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Khách hàng tra cứu danh sách hợp đồng vay vốn và tiến độ trả nợ")
    public ResponseEntity<ApiResponse<CustomerLoanSummaryResponse>> getMyLoans(
            java.security.Principal principal) {

        String customerCode = principal != null ? principal.getName() : "SYSTEM";
        CustomerLoanSummaryResponse summary = customerLoanQueryUseCase.getLoanSummary(customerCode);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(summary, message));
    }
}
