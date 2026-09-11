package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.PaymentWebhookLog;

import java.util.Optional;

/**
 * Cổng giao tiếp lưu vết nhật ký Webhook đối tác thanh toán.
 */
public interface PaymentWebhookLogRepository {

    void save(PaymentWebhookLog webhookLog);

    Optional<PaymentWebhookLog> findByTraceId(String traceId);
}
