package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.SubmitInsuranceClaimRequest;
import com.bmf.mobile.app.dto.response.InsuranceClaimResponse;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.entity.InsuranceClaim;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.repository.InsuranceClaimRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * UseCase tiếp nhận và quản lý hồ sơ yêu cầu trợ cấp bảo hiểm tương hỗ.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SubmitInsuranceClaimUseCase {

    private final InsuranceClaimRepository insuranceClaimRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public InsuranceClaimResponse submitClaim(SubmitInsuranceClaimRequest request, String submittedBy) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);
        String claimId = "CLM-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        log.info("[{}] Submitting insurance claim: id={}, custCode={}, riskType={}, amount={}, submittedBy={}",
                traceId, claimId, request.getCustomerCode(), request.getRiskType(), request.getClaimAmount(), submittedBy);

        LocalDateTime now = LocalDateTime.now();
        InsuranceClaim claim = InsuranceClaim.builder()
                .claimId(claimId)
                .customerCode(request.getCustomerCode())
                .contractCode(request.getContractCode())
                .riskType(request.getRiskType())
                .claimAmount(request.getClaimAmount())
                .medicalDocUrls(request.getMedicalDocUrls())
                .villageHeadDocUrl(request.getVillageHeadDocUrl())
                .description(request.getDescription())
                .status(InsuranceClaimStatus.SUBMITTED)
                .submittedBy(submittedBy)
                .submittedTime(now)
                .build();

        insuranceClaimRepository.save(claim);

        // Sinh Outbox Event gửi thông báo thẩm định Township
        try {
            String payloadJson = objectMapper.writeValueAsString(claim);
            OutboxEvent event = OutboxEvent.builder()
                    .aggregateType("INSURANCE_CLAIM")
                    .aggregateId(claimId)
                    .eventType("INSURANCE_CLAIM_SUBMITTED")
                    .payloadJson(payloadJson)
                    .status(OutboxStatus.PENDING)
                    .retryCount(0)
                    .maxRetries(5)
                    .createdTime(now)
                    .build();
            outboxEventRepository.save(event);
        } catch (Exception ex) {
            log.error("[{}] Failed to serialize Outbox event for insurance claim: {}", traceId, claimId, ex);
        }

        return mapToResponse(claim);
    }

    public List<InsuranceClaimResponse> getMyClaims(String customerCode) {
        List<InsuranceClaim> claims = insuranceClaimRepository.findByCustomerCode(customerCode);
        return claims.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private InsuranceClaimResponse mapToResponse(InsuranceClaim claim) {
        return InsuranceClaimResponse.builder()
                .claimId(claim.getClaimId())
                .customerCode(claim.getCustomerCode())
                .contractCode(claim.getContractCode())
                .riskType(claim.getRiskType())
                .claimAmount(claim.getClaimAmount())
                .status(claim.getStatus())
                .submittedTime(claim.getSubmittedTime())
                .build();
    }
}
