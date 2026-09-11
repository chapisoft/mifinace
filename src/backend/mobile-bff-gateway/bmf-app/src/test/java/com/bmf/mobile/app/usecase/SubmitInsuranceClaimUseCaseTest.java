package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.SubmitInsuranceClaimRequest;
import com.bmf.mobile.app.dto.response.InsuranceClaimResponse;
import com.bmf.mobile.domain.entity.InsuranceClaim;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.InsuranceRiskType;
import com.bmf.mobile.domain.repository.InsuranceClaimRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SubmitInsuranceClaimUseCaseTest {

    @Mock
    private InsuranceClaimRepository insuranceClaimRepository;

    @Mock
    private OutboxEventRepository outboxEventRepository;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private SubmitInsuranceClaimUseCase submitInsuranceClaimUseCase;

    @Test
    @DisplayName("Nộp hồ sơ bảo hiểm tương hỗ thành công - Lưu hồ sơ và sinh Outbox Event")
    void submitClaimSuccess() throws Exception {
        SubmitInsuranceClaimRequest req = SubmitInsuranceClaimRequest.builder()
                .customerCode("CUST-001")
                .contractCode("HD-2026-001")
                .riskType(InsuranceRiskType.HEALTH_SICKNESS)
                .claimAmount(new BigDecimal("30000.00"))
                .description("Nam vien dieu tri sot ret")
                .medicalDocUrls("https://storage.bmf.mm/med_01.jpg")
                .villageHeadDocUrl("https://storage.bmf.mm/village_01.jpg")
                .build();

        when(objectMapper.writeValueAsString(any())).thenReturn("{\"mock\":\"payload\"}");

        InsuranceClaimResponse response = submitInsuranceClaimUseCase.submitClaim(req, "USR001");

        assertNotNull(response);
        assertNotNull(response.getClaimId());
        assertEquals("CUST-001", response.getCustomerCode());
        assertEquals(InsuranceRiskType.HEALTH_SICKNESS, response.getRiskType());
        assertEquals(new BigDecimal("30000.00"), response.getClaimAmount());
        assertEquals(InsuranceClaimStatus.SUBMITTED, response.getStatus());

        verify(insuranceClaimRepository).save(any(InsuranceClaim.class));
        verify(outboxEventRepository).save(any(OutboxEvent.class));
    }

    @Test
    @DisplayName("Khách hàng tra cứu danh sách yêu cầu bồi thường của mình")
    void getMyClaims() {
        InsuranceClaim claim = InsuranceClaim.builder()
                .claimId("CLM-001")
                .customerCode("CUST-001")
                .riskType(InsuranceRiskType.HEALTH_SICKNESS)
                .claimAmount(new BigDecimal("30000.00"))
                .status(InsuranceClaimStatus.SUBMITTED)
                .build();

        when(insuranceClaimRepository.findByCustomerCode("CUST-001")).thenReturn(List.of(claim));

        List<InsuranceClaimResponse> claims = submitInsuranceClaimUseCase.getMyClaims("CUST-001");

        assertNotNull(claims);
        assertEquals(1, claims.size());
        assertEquals("CLM-001", claims.get(0).getClaimId());
    }
}
