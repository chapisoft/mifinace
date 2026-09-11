package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.ConfirmCashHandoverRequest;
import com.bmf.mobile.app.dto.request.GenerateCashHandoverQrRequest;
import com.bmf.mobile.app.dto.response.CashHandoverQrResponse;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.entity.CashHandover;
import com.bmf.mobile.domain.enums.CashHandoverStatus;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.repository.CashHandoverRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;

/**
 * UseCase quản lý đối soát và sinh mã QR bàn giao quỹ tiền mặt lưu động cuối ngày.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CashHandoverUseCase {

    private final CashHandoverRepository cashHandoverRepository;

    private static final String HMAC_SECRET = "BMF_HANDOVER_SECURE_KEY_2026_SECRET_SALT";

    @Transactional
    public CashHandoverQrResponse generateHandoverQr(GenerateCashHandoverQrRequest request, String collectorId) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);
        LocalDate targetDate = (request != null && request.getHandoverDate() != null && !request.getHandoverDate().isBlank())
                ? LocalDate.parse(request.getHandoverDate())
                : LocalDate.now();

        String dateStr = targetDate.format(DateTimeFormatter.BASIC_ISO_DATE);
        String handoverId = "HO-" + dateStr + "-" + collectorId;

        BigDecimal totalAmount = cashHandoverRepository.calculateTotalCashCollectedToday(collectorId, targetDate);
        int totalTransactions = cashHandoverRepository.countTotalTransactionsToday(collectorId, targetDate);

        log.info("[{}] Generating cash handover QR: id={}, collectorId={}, date={}, totalAmount={}, totalTxs={}",
                traceId, handoverId, collectorId, targetDate, totalAmount, totalTransactions);

        String rawDataToSign = handoverId + "|" + totalAmount.toPlainString() + "|" + totalTransactions;
        String signature = signHmacSha256(rawDataToSign, HMAC_SECRET);
        String qrPayload = "BMF_HANDOVER:" + rawDataToSign + "|SIG:" + signature;

        CashHandover handover = CashHandover.builder()
                .handoverId(handoverId)
                .collectorId(collectorId)
                .handoverDate(targetDate)
                .totalAmount(totalAmount)
                .totalTransactions(totalTransactions)
                .qrPayload(qrPayload)
                .qrSignature(signature)
                .status(CashHandoverStatus.PENDING_CONFIRMATION)
                .createdTime(LocalDateTime.now())
                .build();

        cashHandoverRepository.save(handover);

        return CashHandoverQrResponse.builder()
                .handoverId(handover.getHandoverId())
                .collectorId(handover.getCollectorId())
                .handoverDate(handover.getHandoverDate())
                .totalAmount(handover.getTotalAmount())
                .totalTransactions(handover.getTotalTransactions())
                .qrPayload(handover.getQrPayload())
                .status(handover.getStatus())
                .build();
    }

    @Transactional
    public void confirmHandover(ConfirmCashHandoverRequest request, String cashierId) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);

        CashHandover handover = cashHandoverRepository.findById(request.getHandoverId())
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_RESOURCE_NOT_FOUND, "Handover record not found"));

        if (handover.getStatus() == CashHandoverStatus.CONFIRMED) {
            log.warn("[{}] Handover record already confirmed: id={}", traceId, handover.getHandoverId());
            return;
        }

        // Xác thực chữ ký mã QR
        String rawDataToSign = handover.getHandoverId() + "|" + handover.getTotalAmount().toPlainString() + "|" + handover.getTotalTransactions();
        String expectedSignature = signHmacSha256(rawDataToSign, HMAC_SECRET);

        if (!MessageDigest.isEqual(expectedSignature.getBytes(StandardCharsets.UTF_8), handover.getQrSignature().getBytes(StandardCharsets.UTF_8))) {
            log.error("[{}] Invalid handover signature for id={}", traceId, handover.getHandoverId());
            throw new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID, "Invalid cash handover signature");
        }

        cashHandoverRepository.updateStatus(handover.getHandoverId(), CashHandoverStatus.CONFIRMED, cashierId);
        log.info("[{}] Cash handover successfully confirmed by cashier: id={}, cashierId={}",
                traceId, handover.getHandoverId(), cashierId);
    }

    private String signHmacSha256(String data, String secret) {
        try {
            Mac sha256Hmac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            sha256Hmac.init(secretKey);
            byte[] signedBytes = sha256Hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(signedBytes);
        } catch (Exception e) {
            throw new BusinessException(ErrorCode.ERR_INTERNAL_SERVER, "Failed to compute HMAC signature");
        }
    }
}
