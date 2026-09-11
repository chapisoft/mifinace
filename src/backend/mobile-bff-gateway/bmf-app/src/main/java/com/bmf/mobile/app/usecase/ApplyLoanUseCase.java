package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.ApplyLoanRequest;
import com.bmf.mobile.app.dto.response.LoanApplicationResponse;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.entity.LoanApplication;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.LoanApplicationStatus;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.repository.LoanApplicationRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * UseCase tiếp nhận hồ sơ vay vốn thực địa và chấm điểm tín dụng sơ bộ (Credit Scoring).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApplyLoanUseCase {

    private final LoanApplicationRepository loanApplicationRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public LoanApplicationResponse apply(ApplyLoanRequest request, String createdBy) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);
        String applicationId = "APP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        log.info("[{}] Processing field loan application: id={}, custCode={}, requestedAmount={}, createdBy={}",
                traceId, applicationId, request.getCustomerCode(), request.getRequestedAmount(), createdBy);

        // Chấm điểm tín dụng sơ bộ (Credit Scoring Engine)
        int creditScore = calculatePreliminaryCreditScore(request);
        LoanApplicationStatus initialStatus = creditScore >= 600 ? LoanApplicationStatus.SUBMITTED : LoanApplicationStatus.SCORING_REJECTED;

        LocalDateTime now = LocalDateTime.now();
        LoanApplication application = LoanApplication.builder()
                .applicationId(applicationId)
                .customerCode(request.getCustomerCode())
                .customerName(request.getCustomerName())
                .nrcNumber(request.getNrcNumber())
                .groupCode(request.getGroupCode())
                .loanProductCode(request.getLoanProductCode())
                .requestedAmount(request.getRequestedAmount())
                .termMonths(request.getTermMonths())
                .purpose(request.getPurpose())
                .gpsLatitude(request.getGpsLatitude())
                .gpsLongitude(request.getGpsLongitude())
                .nrcFrontImageUrl(request.getNrcFrontImageUrl())
                .nrcBackImageUrl(request.getNrcBackImageUrl())
                .surveyImageUrl(request.getSurveyImageUrl())
                .signatureImageUrl(request.getSignatureImageUrl())
                .status(initialStatus)
                .creditScore(creditScore)
                .createdBy(createdBy)
                .createdTime(now)
                .build();

        loanApplicationRepository.save(application);

        // Sinh Outbox Event gửi thông báo thẩm định
        try {
            String payloadJson = objectMapper.writeValueAsString(application);
            OutboxEvent event = OutboxEvent.builder()
                    .aggregateType("LOAN_APPLICATION")
                    .aggregateId(applicationId)
                    .eventType("LOAN_APPLICATION_SUBMITTED")
                    .payloadJson(payloadJson)
                    .status(OutboxStatus.PENDING)
                    .retryCount(0)
                    .maxRetries(5)
                    .createdTime(now)
                    .build();
            outboxEventRepository.save(event);
        } catch (Exception ex) {
            log.error("[{}] Failed to serialize Outbox event for loan application: {}", traceId, applicationId, ex);
        }

        return LoanApplicationResponse.builder()
                .applicationId(application.getApplicationId())
                .customerCode(application.getCustomerCode())
                .customerName(application.getCustomerName())
                .groupCode(application.getGroupCode())
                .requestedAmount(application.getRequestedAmount())
                .termMonths(application.getTermMonths())
                .status(application.getStatus())
                .creditScore(application.getCreditScore())
                .createdTime(application.getCreatedTime())
                .build();
    }

    private int calculatePreliminaryCreditScore(ApplyLoanRequest request) {
        int score = 650; // Base score
        // Khảo sát hình ảnh và chữ ký đầy đủ
        if (request.getNrcFrontImageUrl() != null && request.getSignatureImageUrl() != null) {
            score += 50;
        }
        if (request.getSurveyImageUrl() != null) {
            score += 30;
        }
        // Vị trí GPS hợp lệ
        if (request.getGpsLatitude() != null && request.getGpsLongitude() != null) {
            score += 20;
        }
        // Hạn mức phù hợp nhóm nghèo vi mô (< 1,000,000 MMK)
        if (request.getRequestedAmount().compareTo(new BigDecimal("1000000.00")) <= 0) {
            score += 30;
        }
        return Math.min(score, 850);
    }
}
