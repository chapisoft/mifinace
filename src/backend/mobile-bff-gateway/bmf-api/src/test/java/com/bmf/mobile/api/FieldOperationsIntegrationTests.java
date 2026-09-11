package com.bmf.mobile.api;

import com.bmf.mobile.app.dto.request.ApplyLoanRequest;
import com.bmf.mobile.app.dto.request.CollectSavingDepositRequest;
import com.bmf.mobile.app.dto.request.ConfirmCashHandoverRequest;
import com.bmf.mobile.app.dto.request.OpenSavingAccountRequest;
import com.bmf.mobile.app.dto.request.SubmitInsuranceClaimRequest;
import com.bmf.mobile.app.dto.response.CashHandoverQrResponse;
import com.bmf.mobile.app.dto.response.InsuranceClaimResponse;
import com.bmf.mobile.app.dto.response.LoanApplicationResponse;
import com.bmf.mobile.app.dto.response.SavingAccountResponse;
import com.bmf.mobile.app.dto.response.SavingTransactionReceiptResponse;
import com.bmf.mobile.app.usecase.ApplyLoanUseCase;
import com.bmf.mobile.app.usecase.CashHandoverUseCase;
import com.bmf.mobile.app.usecase.ManageSavingsUseCase;
import com.bmf.mobile.app.usecase.SubmitInsuranceClaimUseCase;
import com.bmf.mobile.domain.enums.CashHandoverStatus;
import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.InsuranceRiskType;
import com.bmf.mobile.domain.enums.LoanApplicationStatus;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingProductType;
import com.bmf.mobile.domain.enums.SavingTransactionType;
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
class FieldOperationsIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ApplyLoanUseCase applyLoanUseCase;

    @MockBean
    private ManageSavingsUseCase manageSavingsUseCase;

    @MockBean
    private SubmitInsuranceClaimUseCase submitInsuranceClaimUseCase;

    @MockBean
    private CashHandoverUseCase cashHandoverUseCase;

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/loans/apply với ROLE_AGENT nộp hồ sơ vay thành công trả về 200")
    void applyLoanSuccessShouldReturn200() throws Exception {
        ApplyLoanRequest request = ApplyLoanRequest.builder()
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .nrcNumber("12/DAGAMA(N)045612")
                .groupCode("GRP-YGN-01")
                .loanProductCode("MICRO_BIZ_01")
                .requestedAmount(new BigDecimal("500000.00"))
                .termMonths(12)
                .purpose("Mo rong sap hang")
                .build();

        LoanApplicationResponse response = LoanApplicationResponse.builder()
                .applicationId("APP-2026-0089")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .groupCode("GRP-YGN-01")
                .requestedAmount(new BigDecimal("500000.00"))
                .termMonths(12)
                .status(LoanApplicationStatus.SUBMITTED)
                .creditScore(780)
                .createdTime(LocalDateTime.now())
                .build();

        when(applyLoanUseCase.apply(any(ApplyLoanRequest.class), any())).thenReturn(response);

        mockMvc.perform(post("/api/v1/loans/apply")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Nộp hồ sơ vay vốn thực địa thành công"))
                .andExpect(jsonPath("$.data.applicationId").value("APP-2026-0089"))
                .andExpect(jsonPath("$.data.creditScore").value(780));
    }

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/savings/open mở sổ tiết kiệm thành công trả về 200")
    void openSavingAccountShouldReturn200() throws Exception {
        OpenSavingAccountRequest request = OpenSavingAccountRequest.builder()
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .productType(SavingProductType.ACCUMULATIVE)
                .initialDeposit(new BigDecimal("10000.00"))
                .termMonths(6)
                .build();

        SavingAccountResponse response = SavingAccountResponse.builder()
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .productType(SavingProductType.ACCUMULATIVE)
                .balance(new BigDecimal("10000.00"))
                .interestRate(new BigDecimal("10.00"))
                .accruedInterest(BigDecimal.ZERO)
                .termMonths(6)
                .status(SavingAccountStatus.ACTIVE)
                .createdTime(LocalDateTime.now())
                .build();

        when(manageSavingsUseCase.openAccount(any(OpenSavingAccountRequest.class), any())).thenReturn(response);

        mockMvc.perform(post("/api/v1/savings/open")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.accountNumber").value("SA-2026-0099"));
    }

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/savings/collect nộp tiền tiết kiệm thành công trả về 200")
    void collectSavingDepositShouldReturn200() throws Exception {
        CollectSavingDepositRequest request = CollectSavingDepositRequest.builder()
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .amount(new BigDecimal("5000.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-SAV-001")
                .build();

        SavingTransactionReceiptResponse receipt = SavingTransactionReceiptResponse.builder()
                .transactionId("TX-SAV-001")
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .amount(new BigDecimal("5000.00"))
                .newBalance(new BigDecimal("15000.00"))
                .transactionType(SavingTransactionType.DEPOSIT)
                .paymentMethod(RepaymentMethod.CASH)
                .status(RepaymentStatus.COLLECTED)
                .transactionTime(LocalDateTime.now())
                .build();

        when(manageSavingsUseCase.collectDeposit(any(CollectSavingDepositRequest.class), any())).thenReturn(receipt);

        mockMvc.perform(post("/api/v1/savings/collect")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.transactionId").value("TX-SAV-001"))
                .andExpect(jsonPath("$.data.newBalance").value(15000.00));
    }

    @Test
    @WithMockUser(username = "CUST-001", roles = {"CUSTOMER"})
    @DisplayName("Endpoint POST /api/v1/insurance/claim nộp hồ sơ bảo hiểm thành công trả về 200")
    void submitInsuranceClaimShouldReturn200() throws Exception {
        SubmitInsuranceClaimRequest request = SubmitInsuranceClaimRequest.builder()
                .customerCode("CUST-001")
                .riskType(InsuranceRiskType.HEALTH_SICKNESS)
                .claimAmount(new BigDecimal("30000.00"))
                .description("Sot ret")
                .build();

        InsuranceClaimResponse response = InsuranceClaimResponse.builder()
                .claimId("CLM-2026-0045")
                .customerCode("CUST-001")
                .riskType(InsuranceRiskType.HEALTH_SICKNESS)
                .claimAmount(new BigDecimal("30000.00"))
                .status(InsuranceClaimStatus.SUBMITTED)
                .submittedTime(LocalDateTime.now())
                .build();

        when(submitInsuranceClaimUseCase.submitClaim(any(SubmitInsuranceClaimRequest.class), any())).thenReturn(response);

        mockMvc.perform(post("/api/v1/insurance/claim")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.claimId").value("CLM-2026-0045"));
    }

    @Test
    @WithMockUser(username = "USR001", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/cash/handover-qr sinh mã QR bàn giao quỹ thành công trả về 200")
    void generateCashHandoverQrShouldReturn200() throws Exception {
        CashHandoverQrResponse response = CashHandoverQrResponse.builder()
                .handoverId("HO-20260915-USR001")
                .collectorId("USR001")
                .handoverDate(LocalDate.parse("2026-09-15"))
                .totalAmount(new BigDecimal("1250000.00"))
                .totalTransactions(25)
                .qrPayload("BMF_HANDOVER:HO-20260915-USR001|1250000.00|25|SIG:mock_sig")
                .status(CashHandoverStatus.PENDING_CONFIRMATION)
                .build();

        when(cashHandoverUseCase.generateHandoverQr(any(), eq("USR001"))).thenReturn(response);

        mockMvc.perform(post("/api/v1/cash/handover-qr"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.handoverId").value("HO-20260915-USR001"))
                .andExpect(jsonPath("$.data.totalAmount").value(1250000.00));
    }

    @Test
    @WithMockUser(username = "CASHIER01", roles = {"AGENT"})
    @DisplayName("Endpoint POST /api/v1/cash/handover/confirm xác nhận nhập quỹ thành công trả về 200")
    void confirmCashHandoverShouldReturn200() throws Exception {
        ConfirmCashHandoverRequest request = ConfirmCashHandoverRequest.builder()
                .handoverId("HO-20260915-USR001")
                .qrPayload("BMF_HANDOVER:HO-20260915-USR001|1250000.00|25|SIG:mock_sig")
                .build();

        mockMvc.perform(post("/api/v1/cash/handover/confirm")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
