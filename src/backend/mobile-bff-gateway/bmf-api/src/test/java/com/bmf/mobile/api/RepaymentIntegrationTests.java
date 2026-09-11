package com.bmf.mobile.api;

import com.bmf.mobile.app.dto.request.BatchRepaymentSyncRequest;
import com.bmf.mobile.app.dto.request.CollectRepaymentRequest;
import com.bmf.mobile.app.dto.request.SyncScheduleRequest;
import com.bmf.mobile.app.dto.response.BatchSyncSummaryResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanSummaryResponse;
import com.bmf.mobile.app.dto.response.RepaymentReceiptResponse;
import com.bmf.mobile.app.dto.response.ScheduleSyncResponse;
import com.bmf.mobile.app.usecase.BatchRepaymentSyncUseCase;
import com.bmf.mobile.app.usecase.CollectRepaymentUseCase;
import com.bmf.mobile.app.usecase.CustomerLoanQueryUseCase;
import com.bmf.mobile.app.usecase.SyncRepaymentScheduleUseCase;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
        "spring.autoconfigure.exclude=org.redisson.spring.starter.RedissonAutoConfigurationV2"
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestConfig.class)
class RepaymentIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private SyncRepaymentScheduleUseCase syncRepaymentScheduleUseCase;

    @MockBean
    private CollectRepaymentUseCase collectRepaymentUseCase;

    @MockBean
    private BatchRepaymentSyncUseCase batchRepaymentSyncUseCase;

    @MockBean
    private CustomerLoanQueryUseCase customerLoanQueryUseCase;

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint GET /api/v1/loans/schedules/sync với ROLE_AGENT thành công trả về HTTP 200")
    void syncScheduleWithAgentRoleShouldReturn200() throws Exception {
        ScheduleSyncResponse response = ScheduleSyncResponse.builder()
                .groupCode("GRP-YGN-01")
                .dueDate("2026-09-15")
                .totalMembers(10)
                .totalExpectedAmount(new BigDecimal("500000.00"))
                .schedules(Collections.emptyList())
                .serverTime(System.currentTimeMillis())
                .build();

        when(syncRepaymentScheduleUseCase.syncSchedule(any(SyncScheduleRequest.class))).thenReturn(response);

        mockMvc.perform(get("/api/v1/loans/schedules/sync")
                        .param("groupCode", "GRP-YGN-01")
                        .param("dueDate", "2026-09-15")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Đồng bộ lịch thu nợ Cụm/Tổ thành công"))
                .andExpect(jsonPath("$.data.groupCode").value("GRP-YGN-01"))
                .andExpect(jsonPath("$.data.totalMembers").value(10));
    }

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/loans/repayments/collect với ROLE_AGENT gạch nợ thành công trả về 200")
    void collectRepaymentWithAgentRoleShouldReturn200() throws Exception {
        CollectRepaymentRequest request = CollectRepaymentRequest.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .periodNumber(1)
                .principalAmount(new BigDecimal("50000.00"))
                .interestAmount(new BigDecimal("6250.00"))
                .insuranceFee(new BigDecimal("1000.00"))
                .compulsorySaving(new BigDecimal("2000.00"))
                .totalAmount(new BigDecimal("59250.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-001")
                .build();

        RepaymentReceiptResponse receipt = RepaymentReceiptResponse.builder()
                .transactionId("TX-123456")
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .periodNumber(1)
                .paidAmount(new BigDecimal("59250.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .status(RepaymentStatus.COLLECTED)
                .build();

        when(collectRepaymentUseCase.collect(any(CollectRepaymentRequest.class), any())).thenReturn(receipt);

        mockMvc.perform(post("/api/v1/loans/repayments/collect")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "my")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("ချေးငွေ ပေးချေမှု အောင်မြင်စွာ လက်ခံပြီးပါပြီ"))
                .andExpect(jsonPath("$.data.transactionId").value("TX-123456"))
                .andExpect(jsonPath("$.data.paidAmount").value(59250.00));
    }

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/loans/repayments/batch-sync với ROLE_AGENT đồng bộ mẻ thành công")
    void batchSyncWithAgentRoleShouldReturn200() throws Exception {
        CollectRepaymentRequest req = CollectRepaymentRequest.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .periodNumber(1)
                .totalAmount(new BigDecimal("59250.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-001")
                .build();

        BatchRepaymentSyncRequest batchRequest = BatchRepaymentSyncRequest.builder()
                .repayments(List.of(req))
                .build();

        BatchSyncSummaryResponse summary = BatchSyncSummaryResponse.builder()
                .totalSubmitted(1)
                .totalSuccess(1)
                .totalFailed(0)
                .totalAmountProcessed(new BigDecimal("59250.00"))
                .receipts(Collections.emptyList())
                .failedItems(Collections.emptyList())
                .build();

        when(batchRepaymentSyncUseCase.syncBatch(any(BatchRepaymentSyncRequest.class), any())).thenReturn(summary);

        mockMvc.perform(post("/api/v1/loans/repayments/batch-sync")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(batchRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.totalSuccess").value(1));
    }

    @Test
    @WithMockUser(username = "CUST-001", roles = {"CUSTOMER"})
    @DisplayName("Endpoint GET /api/v1/loans/my-loans với ROLE_CUSTOMER thành công trả về 200")
    void getMyLoansWithCustomerRoleShouldReturn200() throws Exception {
        CustomerLoanSummaryResponse summary = CustomerLoanSummaryResponse.builder()
                .customerCode("CUST-001")
                .fullName("Daw Khin Myint")
                .groupCode("GRP-YGN-01")
                .totalOutstandingPrincipal(new BigDecimal("450000.00"))
                .totalPeriodsPaid(2)
                .totalPeriodsRemaining(10)
                .schedules(Collections.emptyList())
                .build();

        when(customerLoanQueryUseCase.getLoanSummary(eq("CUST-001"))).thenReturn(summary);

        mockMvc.perform(get("/api/v1/loans/my-loans"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.customerCode").value("CUST-001"))
                .andExpect(jsonPath("$.data.totalPeriodsPaid").value(2));
    }

    @Test
    @WithMockUser(username = "CUST-001", roles = {"CUSTOMER"})
    @DisplayName("Endpoint POST /api/v1/loans/repayments/collect bị chặn HTTP 403 khi gọi bởi ROLE_CUSTOMER (RBAC)")
    void collectRepaymentWithCustomerRoleShouldReturn403Forbidden() throws Exception {
        CollectRepaymentRequest request = CollectRepaymentRequest.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .periodNumber(1)
                .totalAmount(new BigDecimal("59250.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-001")
                .build();

        mockMvc.perform(post("/api/v1/loans/repayments/collect")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Endpoint GET /api/v1/loans/my-loans bị chặn HTTP 401 khi không có Token")
    void getMyLoansWithoutTokenShouldReturn401Unauthorized() throws Exception {
        mockMvc.perform(get("/api/v1/loans/my-loans"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorCode").value("ERR_UNAUTHORIZED"));
    }
}
