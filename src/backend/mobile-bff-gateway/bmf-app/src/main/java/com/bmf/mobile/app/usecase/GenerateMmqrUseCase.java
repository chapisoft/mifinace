package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.GenerateMmqrRequest;
import com.bmf.mobile.app.dto.response.MmqrResponse;
import com.bmf.mobile.domain.entity.PaymentOrder;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PaymentOrderStatus;
import com.bmf.mobile.domain.enums.PaymentProvider;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.MmqrGeneratorPort;
import com.bmf.mobile.domain.repository.PaymentOrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * UseCase sinh mã MMQR động EMVCo cho từng kỳ thu nợ của khách hàng.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GenerateMmqrUseCase {

    private final MmqrGeneratorPort mmqrGeneratorPort;
    private final PaymentOrderRepository paymentOrderRepository;

    private static final String MERCHANT_NAME = "BMF MICROFINANCE";
    private static final String MERCHANT_CITY = "YANGON";
    private static final String CURRENCY_MMK = "MMK";

    public MmqrResponse generateMmqr(GenerateMmqrRequest request) {
        log.info("Processing MMQR generation: loanCode={}, scheduleId={}, amount={}",
                request.getLoanCode(), request.getScheduleId(), request.getAmount());

        if (request.getAmount() == null || request.getAmount().signum() <= 0) {
            throw new BusinessException(ErrorCode.ERR_AMOUNT_INVALID);
        }

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String randomSuffix = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String orderNo = "ORD-MMQR-" + timestamp + "-" + randomSuffix;
        String billReference = request.getLoanCode() + "-P" + request.getScheduleId();

        // Sinh chuỗi MMQR EMVCo chuẩn CBM
        String mmqrPayload = mmqrGeneratorPort.generateMmqrPayload(
                MERCHANT_NAME,
                MERCHANT_CITY,
                billReference,
                request.getAmount(),
                CURRENCY_MMK
        );

        // Sinh ảnh QR Code Base64 (kích thước 300x300 px)
        String qrImageBase64 = mmqrGeneratorPort.generateQrCodeBase64(mmqrPayload, 300, 300);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiredTime = now.plusMinutes(15);

        PaymentOrder paymentOrder = PaymentOrder.builder()
                .orderNo(orderNo)
                .loanCode(request.getLoanCode())
                .scheduleId(request.getScheduleId())
                .amount(request.getAmount())
                .currency(CURRENCY_MMK)
                .provider(PaymentProvider.MMQR)
                .status(PaymentOrderStatus.PENDING)
                .mmqrPayload(mmqrPayload)
                .expiredTime(expiredTime)
                .createdTime(now)
                .updatedTime(now)
                .build();

        paymentOrderRepository.save(paymentOrder);

        log.info("MMQR generated successfully: orderNo={}, expiredTime={}", orderNo, expiredTime);

        return MmqrResponse.builder()
                .orderNo(orderNo)
                .loanCode(request.getLoanCode())
                .scheduleId(request.getScheduleId())
                .amount(request.getAmount())
                .currency(CURRENCY_MMK)
                .mmqrString(mmqrPayload)
                .qrImageBase64(qrImageBase64)
                .expiredTime(expiredTime)
                .merchantName(MERCHANT_NAME)
                .billReference(billReference)
                .build();
    }
}
