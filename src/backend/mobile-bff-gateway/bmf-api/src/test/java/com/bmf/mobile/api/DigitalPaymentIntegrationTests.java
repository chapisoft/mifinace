package com.bmf.mobile.api;

import com.bmf.mobile.app.dto.request.GenerateMmqrRequest;
import com.bmf.mobile.app.dto.request.OpenSavingAccountRequest;
import com.bmf.mobile.app.dto.request.SubmitInsuranceClaimRequest;
import com.bmf.mobile.app.dto.request.WebhookPaymentRequest;
import com.bmf.mobile.app.dto.response.CustomerInsuranceBenefitResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanScheduleItemResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanScheduleResponse;
import com.bmf.mobile.app.dto.response.CustomerLoanSummaryResponse;
import com.bmf.mobile.app.dto.response.InsuranceClaimResponse;
import com.bmf.mobile.app.dto.response.MmqrResponse;
import com.bmf.mobile.app.dto.response.SavingAccountResponse;
import com.bmf.mobile.app.dto.response.WebhookPaymentResponse;
import com.bmf.mobile.app.usecase.CustomerBenefitQueryUseCase;
import com.bmf.mobile.app.usecase.CustomerLoanQueryUseCase;
import com.bmf.mobile.app.usecase.GenerateMmqrUseCase;
import com.bmf.mobile.app.usecase.ManageSavingsUseCase;
import com.bmf.mobile.app.usecase.ProcessWebhookPaymentUseCase;
import com.bmf.mobile.app.usecase.SubmitInsuranceClaimUseCase;
import com.bmf.mobile.domain.enums.DebtClassificationGroup;
import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.InsuranceRiskType;
import com.bmf.mobile.domain.enums.PaymentProvider;
import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingProductType;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
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
@SuppressWarnings("null")
@DisplayName("Sprint 4 Integration Tests: Digital Payments, MMQR, Webhooks & Customer APIs")
class DigitalPaymentIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private CustomerLoanQueryUseCase customerLoanQueryUseCase;

    @MockBean
    private ManageSavingsUseCase manageSavingsUseCase;

    @MockBean
    private SubmitInsuranceClaimUseCase submitInsuranceClaimUseCase;

    @MockBean
    private CustomerBenefitQueryUseCase customerBenefitQueryUseCase;

    @MockBean
    private GenerateMmqrUseCase generateMmqrUseCase;

    @MockBean
    private ProcessWebhookPaymentUseCase processWebhookPaymentUseCase;

    private static final String TEST_CUSTOMER_CODE = "CUST-9001";
    private static final String TEST_LOAN_CODE = "LN-BMF-2026-9001";

    @Test
    @WithMockUser(username = TEST_CUSTOMER_CODE, roles = {"CUSTOMER"})
    @DisplayName("TASK-BFF-05.8: Khách hàng tra cứu danh sách khoản vay trả về 200")
    void testGetCustomerLoans() throws Exception {
        CustomerLoanSummaryResponse summary = CustomerLoanSummaryResponse.builder()
                .customerCode(TEST_CUSTOMER_CODE)
                .fullName("Daw Mya Mya")
                .groupCode("GRP-YGN-01")
                .totalOutstandingPrincipal(new BigDecimal("100000.00"))
                .totalPeriodsPaid(5)
                .totalPeriodsRemaining(7)
                .schedules(Collections.emptyList())
                .build();

        when(customerLoanQueryUseCase.getLoanSummary(TEST_CUSTOMER_CODE)).thenReturn(summary);

        mockMvc.perform(get("/api/v1/customer/loans")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.customerCode").value(TEST_CUSTOMER_CODE))
                .andExpect(jsonPath("$.data.totalOutstandingPrincipal").value(100000.00));
    }

    @Test
    @WithMockUser(username = TEST_CUSTOMER_CODE, roles = {"CUSTOMER"})
    @DisplayName("TASK-BFF-05.9: Khách hàng tra cứu lịch trả nợ toàn khóa 5 nhóm nợ FRD")
    void testGetCustomerLoanScheduleWithFrdDebtGroups() throws Exception {
        CustomerLoanScheduleItemResponse item1 = CustomerLoanScheduleItemResponse.builder()
                .scheduleId(1L)
                .installmentNo(1)
                .dueDate(LocalDate.now().minusDays(10))
                .principalAmount(new BigDecimal("50000.00"))
                .interestAmount(new BigDecimal("2500.00"))
                .compulsorySavingAmount(new BigDecimal("2000.00"))
                .insuranceFee(new BigDecimal("500.00"))
                .totalDueAmount(new BigDecimal("55000.00"))
                .paidAmount(BigDecimal.ZERO)
                .status("PENDING")
                .overdueDays(10)
                .debtGroup(DebtClassificationGroup.GROUP_1_CURRENT.name())
                .debtGroupDescription(DebtClassificationGroup.GROUP_1_CURRENT.getDescription())
                .build();

        CustomerLoanScheduleResponse response = CustomerLoanScheduleResponse.builder()
                .loanCode(TEST_LOAN_CODE)
                .customerCode(TEST_CUSTOMER_CODE)
                .customerName("Daw Mya Mya")
                .totalPrincipal(new BigDecimal("100000.00"))
                .remainingPrincipal(new BigDecimal("100000.00"))
                .totalInstallments(2)
                .paidInstallments(0)
                .maxOverdueDays(10)
                .currentDebtGroup(DebtClassificationGroup.GROUP_1_CURRENT.name())
                .currentDebtGroupDescription(DebtClassificationGroup.GROUP_1_CURRENT.getDescription())
                .schedules(List.of(item1))
                .build();

        when(customerLoanQueryUseCase.getLoanScheduleDetail(TEST_CUSTOMER_CODE, TEST_LOAN_CODE)).thenReturn(response);

        mockMvc.perform(get("/api/v1/customer/loans/{loanId}/schedule", TEST_LOAN_CODE)
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.loanCode").value(TEST_LOAN_CODE))
                .andExpect(jsonPath("$.data.currentDebtGroup").value("GROUP_1_CURRENT"));
    }

    @Test
    @WithMockUser(username = TEST_CUSTOMER_CODE, roles = {"CUSTOMER"})
    @DisplayName("TASK-BFF-05.10: Khách hàng tra cứu danh mục sổ tiết kiệm và lãi dồn tích")
    void testGetCustomerSavings() throws Exception {
        SavingAccountResponse acc = SavingAccountResponse.builder()
                .accountNumber("SAV-9001-01")
                .customerCode(TEST_CUSTOMER_CODE)
                .customerName("Daw Mya Mya")
                .productType(SavingProductType.VOLUNTARY)
                .balance(new BigDecimal("150000.00"))
                .accruedInterest(new BigDecimal("3500.00"))
                .interestRate(new BigDecimal("8.00"))
                .termMonths(12)
                .status(SavingAccountStatus.ACTIVE)
                .createdTime(LocalDateTime.now())
                .build();

        when(manageSavingsUseCase.getMySavingAccounts(TEST_CUSTOMER_CODE)).thenReturn(List.of(acc));

        mockMvc.perform(get("/api/v1/customer/savings")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.customerCode").value(TEST_CUSTOMER_CODE))
                .andExpect(jsonPath("$.data.totalSavingsBalance").value(150000.00));
    }

    @Test
    @WithMockUser(username = TEST_CUSTOMER_CODE, roles = {"CUSTOMER"})
    @DisplayName("TASK-BFF-05.11: Khách hàng mở sổ tiết kiệm tích lũy online")
    void testOpenSavingOnline() throws Exception {
        OpenSavingAccountRequest request = OpenSavingAccountRequest.builder()
                .customerCode(TEST_CUSTOMER_CODE)
                .customerName("Daw Mya Mya")
                .productType(SavingProductType.COMPULSORY)
                .initialDeposit(new BigDecimal("50000.00"))
                .termMonths(6)
                .beneficiaryName("U Kyaw Kyaw")
                .beneficiaryNrc("12/DAGAMA(N)112233")
                .build();

        SavingAccountResponse response = SavingAccountResponse.builder()
                .accountNumber("SAV-2026-9999")
                .customerCode(TEST_CUSTOMER_CODE)
                .customerName("Daw Mya Mya")
                .productType(SavingProductType.COMPULSORY)
                .balance(new BigDecimal("50000.00"))
                .accruedInterest(BigDecimal.ZERO)
                .interestRate(new BigDecimal("7.50"))
                .termMonths(6)
                .status(SavingAccountStatus.ACTIVE)
                .createdTime(LocalDateTime.now())
                .build();

        when(manageSavingsUseCase.openAccount(any(OpenSavingAccountRequest.class), any())).thenReturn(response);

        mockMvc.perform(post("/api/v1/customer/savings/open")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.accountNumber").value("SAV-2026-9999"));
    }

    @Test
    @WithMockUser(username = TEST_CUSTOMER_CODE, roles = {"CUSTOMER"})
    @DisplayName("TASK-BFF-05.12: Khách hàng tra cứu quyền lợi và nộp hồ sơ bảo hiểm trực tuyến")
    void testCustomerInsuranceBenefitsAndClaim() throws Exception {
        CustomerInsuranceBenefitResponse benefitResponse = CustomerInsuranceBenefitResponse.builder()
                .customerCode(TEST_CUSTOMER_CODE)
                .memberName("Daw Mya Mya")
                .policyNumber("POL-BMF-9001")
                .maxHospitalizationBenefit(new BigDecimal("200000.00"))
                .maxAccidentBenefit(new BigDecimal("500000.00"))
                .maxLifeBenefit(new BigDecimal("1000000.00"))
                .annualContributionFee(new BigDecimal("12000.00"))
                .benefitDescriptionMyanmar("အကျိုးခံစားခွင့်")
                .claimProcedureMyanmar("လုပ်ထုံးလုပ်နည်း")
                .emergencyHotline("+95 1 234 5678")
                .build();

        when(customerBenefitQueryUseCase.getInsuranceBenefits(TEST_CUSTOMER_CODE)).thenReturn(benefitResponse);

        mockMvc.perform(get("/api/v1/customer/insurance/benefits")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "my")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.policyNumber").value("POL-BMF-9001"))
                .andExpect(jsonPath("$.data.maxHospitalizationBenefit").value(200000.00));

        SubmitInsuranceClaimRequest claimRequest = SubmitInsuranceClaimRequest.builder()
                .customerCode(TEST_CUSTOMER_CODE)
                .contractCode(TEST_LOAN_CODE)
                .riskType(InsuranceRiskType.HEALTH_SICKNESS)
                .claimAmount(new BigDecimal("100000.00"))
                .description("Hospitalization at Township General Hospital")
                .medicalDocUrls("https://bmf.com.mm/docs/claim1.jpg")
                .villageHeadDocUrl("https://bmf.com.mm/docs/village.jpg")
                .build();

        InsuranceClaimResponse claimResponse = InsuranceClaimResponse.builder()
                .claimId("CLM-2026-0099")
                .customerCode(TEST_CUSTOMER_CODE)
                .contractCode(TEST_LOAN_CODE)
                .riskType(InsuranceRiskType.HEALTH_SICKNESS)
                .claimAmount(new BigDecimal("100000.00"))
                .status(InsuranceClaimStatus.SUBMITTED)
                .submittedTime(LocalDateTime.now())
                .build();

        when(submitInsuranceClaimUseCase.submitClaim(any(SubmitInsuranceClaimRequest.class), any())).thenReturn(claimResponse);

        mockMvc.perform(post("/api/v1/customer/insurance/claim")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(claimRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.claimId").value("CLM-2026-0099"));
    }

    @Test
    @WithMockUser(username = TEST_CUSTOMER_CODE, roles = {"CUSTOMER"})
    @DisplayName("TASK-BFF-06.1: Sinh mã MMQR động EMVCo CBM kèm ảnh Base64")
    void testGenerateMmqr() throws Exception {
        GenerateMmqrRequest request = GenerateMmqrRequest.builder()
                .loanCode(TEST_LOAN_CODE)
                .scheduleId(1L)
                .amount(new BigDecimal("55000.00"))
                .build();

        MmqrResponse response = MmqrResponse.builder()
                .orderNo("ORD-MMQR-20260911-A1B2C3D4")
                .loanCode(TEST_LOAN_CODE)
                .scheduleId(1L)
                .amount(new BigDecimal("55000.00"))
                .currency("MMK")
                .mmqrString("000201010212520460125303104540855000.005802MM5916BMF MICROFINANCE6006YANGON6304A1B2")
                .qrImageBase64("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...")
                .expiredTime(LocalDateTime.now().plusMinutes(15))
                .merchantName("BMF MICROFINANCE")
                .billReference(TEST_LOAN_CODE + "-P1")
                .build();

        when(generateMmqrUseCase.generateMmqr(any(GenerateMmqrRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/v1/payments/mmqr")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.orderNo").value("ORD-MMQR-20260911-A1B2C3D4"))
                .andExpect(jsonPath("$.data.currency").value("MMK"));
    }

    @Test
    @DisplayName("TASK-BFF-06.2 & 06.3: Webhook KBZPay và WavePay gạch nợ tự động")
    void testProcessPaymentWebhooks() throws Exception {
        WebhookPaymentRequest webhookReq = WebhookPaymentRequest.builder()
                .orderNo("ORD-MMQR-20260911-A1B2C3D4")
                .partnerRefNo("KBZ-TXN-123456")
                .amount(new BigDecimal("55000.00"))
                .currency("MMK")
                .timestamp(String.valueOf(System.currentTimeMillis()))
                .signature("VALID_SIGNATURE_KBZPAY")
                .partnerStatus("SUCCESS")
                .build();

        WebhookPaymentResponse webhookResp = WebhookPaymentResponse.builder()
                .code("0")
                .message("SUCCESS")
                .orderNo("ORD-MMQR-20260911-A1B2C3D4")
                .partnerRefNo("KBZ-TXN-123456")
                .settledTime(LocalDateTime.now())
                .build();

        when(processWebhookPaymentUseCase.processWebhook(eq(PaymentProvider.KBZPAY), any(WebhookPaymentRequest.class), any()))
                .thenReturn(webhookResp);
        when(processWebhookPaymentUseCase.processWebhook(eq(PaymentProvider.WAVEPAY), any(WebhookPaymentRequest.class), any()))
                .thenReturn(webhookResp);

        // 1. KBZPay Webhook
        mockMvc.perform(post("/api/v1/payments/webhook/kbzpay")
                        .header("X-Trace-Id", "TRACE-KBZ-001")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(webhookReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.code").value("0"))
                .andExpect(jsonPath("$.data.orderNo").value("ORD-MMQR-20260911-A1B2C3D4"));

        // 2. WavePay Webhook
        mockMvc.perform(post("/api/v1/payments/webhook/wavepay")
                        .header("X-Trace-Id", "TRACE-WAVE-001")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(webhookReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.code").value("0"));
    }

    @Test
    @DisplayName("TASK-BFF-06.4: Webhook AYA Pay & MytelPay gạch nợ tự động")
    void testAyaPayAndMytelPayWebhooks() throws Exception {
        WebhookPaymentRequest webhookReq = WebhookPaymentRequest.builder()
                .orderNo("ORD-MMQR-20260911-A1B2C3D4")
                .partnerRefNo("AYA-TXN-789012")
                .amount(new BigDecimal("55000.00"))
                .currency("MMK")
                .timestamp(String.valueOf(System.currentTimeMillis()))
                .signature("VALID_SIGNATURE_AYAPAY")
                .partnerStatus("SUCCESS")
                .build();

        WebhookPaymentResponse webhookResp = WebhookPaymentResponse.builder()
                .code("0")
                .message("SUCCESS")
                .orderNo("ORD-MMQR-20260911-A1B2C3D4")
                .partnerRefNo("AYA-TXN-789012")
                .settledTime(LocalDateTime.now())
                .build();

        when(processWebhookPaymentUseCase.processWebhook(eq(PaymentProvider.AYAPAY), any(WebhookPaymentRequest.class), any()))
                .thenReturn(webhookResp);
        when(processWebhookPaymentUseCase.processWebhook(eq(PaymentProvider.MYTELPAY), any(WebhookPaymentRequest.class), any()))
                .thenReturn(webhookResp);

        // AYA Pay
        mockMvc.perform(post("/api/v1/payments/webhook/ayapay")
                        .header("X-Trace-Id", "TRACE-AYA-001")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(webhookReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.code").value("0"));

        // MytelPay
        mockMvc.perform(post("/api/v1/payments/webhook/mytelpay")
                        .header("X-Trace-Id", "TRACE-MYTEL-001")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(webhookReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.code").value("0"));
    }
}
