package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.WebhookPaymentRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.WebhookPaymentResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.ProcessWebhookPaymentUseCase;
import com.bmf.mobile.domain.enums.PaymentProvider;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Controller tiếp nhận Webhook gạch nợ tự động thời gian thực từ các cổng ví điện tử Myanmar.
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/payments/webhook")
@RequiredArgsConstructor
@Tag(name = "12. Payment Webhook Receivers", description = "Tiếp nhận webhook thanh toán tự động thời gian thực từ KBZPay, WavePay, AYA Pay và MytelPay")
public class PaymentWebhookController {

    private final ProcessWebhookPaymentUseCase processWebhookPaymentUseCase;
    private final I18nService i18nService;

    @PostMapping("/kbzpay")
    @Operation(summary = "TASK-BFF-06.2: Webhook tiếp nhận thanh toán từ KBZPay (KBZ Bank)")
    public ResponseEntity<ApiResponse<WebhookPaymentResponse>> receiveKbzPayWebhook(
            @Valid @RequestBody WebhookPaymentRequest request,
            @RequestHeader(value = "X-Trace-Id", required = false) String traceId,
            HttpServletRequest httpRequest) {

        String effectiveTraceId = traceId != null ? traceId : UUID.randomUUID().toString();
        log.info("Received KBZPay webhook request: orderNo={}, ref={}", request.getOrderNo(), request.getPartnerRefNo());

        WebhookPaymentResponse response = processWebhookPaymentUseCase.processWebhook(
                PaymentProvider.KBZPAY, request, effectiveTraceId);

        String message = i18nService.getMessage("msg.payment.webhook.processed");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/wavepay")
    @Operation(summary = "TASK-BFF-06.3: Webhook tiếp nhận thanh toán từ WavePay (Wave Money)")
    public ResponseEntity<ApiResponse<WebhookPaymentResponse>> receiveWavePayWebhook(
            @Valid @RequestBody WebhookPaymentRequest request,
            @RequestHeader(value = "X-Trace-Id", required = false) String traceId) {

        String effectiveTraceId = traceId != null ? traceId : UUID.randomUUID().toString();
        log.info("Received WavePay webhook request: orderNo={}, ref={}", request.getOrderNo(), request.getPartnerRefNo());

        WebhookPaymentResponse response = processWebhookPaymentUseCase.processWebhook(
                PaymentProvider.WAVEPAY, request, effectiveTraceId);

        String message = i18nService.getMessage("msg.payment.webhook.processed");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/ayapay")
    @Operation(summary = "TASK-BFF-06.4: Webhook tiếp nhận thanh toán từ AYA Pay")
    public ResponseEntity<ApiResponse<WebhookPaymentResponse>> receiveAyaPayWebhook(
            @Valid @RequestBody WebhookPaymentRequest request,
            @RequestHeader(value = "X-Trace-Id", required = false) String traceId) {

        String effectiveTraceId = traceId != null ? traceId : UUID.randomUUID().toString();
        log.info("Received AYA Pay webhook request: orderNo={}, ref={}", request.getOrderNo(), request.getPartnerRefNo());

        WebhookPaymentResponse response = processWebhookPaymentUseCase.processWebhook(
                PaymentProvider.AYAPAY, request, effectiveTraceId);

        String message = i18nService.getMessage("msg.payment.webhook.processed");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/mytelpay")
    @Operation(summary = "TASK-BFF-06.4: Webhook tiếp nhận thanh toán từ MytelPay")
    public ResponseEntity<ApiResponse<WebhookPaymentResponse>> receiveMytelPayWebhook(
            @Valid @RequestBody WebhookPaymentRequest request,
            @RequestHeader(value = "X-Trace-Id", required = false) String traceId) {

        String effectiveTraceId = traceId != null ? traceId : UUID.randomUUID().toString();
        log.info("Received MytelPay webhook request: orderNo={}, ref={}", request.getOrderNo(), request.getPartnerRefNo());

        WebhookPaymentResponse response = processWebhookPaymentUseCase.processWebhook(
                PaymentProvider.MYTELPAY, request, effectiveTraceId);

        String message = i18nService.getMessage("msg.payment.webhook.processed");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }
}
