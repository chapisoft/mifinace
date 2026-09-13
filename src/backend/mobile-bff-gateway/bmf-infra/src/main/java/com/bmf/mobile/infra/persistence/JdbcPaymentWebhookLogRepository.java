package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.PaymentWebhookLog;
import com.bmf.mobile.domain.enums.PaymentProvider;
import com.bmf.mobile.domain.repository.PaymentWebhookLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Optional;

/**
 * Triển khai JDBC lưu vết bảng SYS_PAYMENT_WEBHOOK_LOG trên SQL Server.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcPaymentWebhookLogRepository implements PaymentWebhookLogRepository {

    private final JdbcClient jdbcClient;

    @Override
    public void save(PaymentWebhookLog webhookLog) {
        String sql = """
            INSERT INTO dbo.SYS_PAYMENT_WEBHOOK_LOG (
                Provider, Order_No, Request_Payload, Response_Payload, Signature, Status, Trace_Id, Created_Time
            ) VALUES (
                :provider, :orderNo, :requestPayload, :responsePayload, :signature, :status, :traceId, :createdTime
            )
            """;

        jdbcClient.sql(sql)
                .param("provider", webhookLog.getProvider().name())
                .param("orderNo", webhookLog.getOrderNo())
                .param("requestPayload", webhookLog.getRequestPayload())
                .param("responsePayload", webhookLog.getResponsePayload())
                .param("signature", webhookLog.getSignature())
                .param("status", webhookLog.getStatus())
                .param("traceId", webhookLog.getTraceId())
                .param("createdTime", Timestamp.valueOf(webhookLog.getCreatedTime()))
                .update();
        log.info("Saved webhook log to database: traceId={}, provider={}", webhookLog.getTraceId(), webhookLog.getProvider());
    }

    @Override
    public Optional<PaymentWebhookLog> findByTraceId(String traceId) {
        String sql = """
            SELECT Id, Provider, Order_No, Request_Payload, Response_Payload, Signature, Status, Trace_Id, Created_Time
            FROM dbo.SYS_PAYMENT_WEBHOOK_LOG
            WHERE Trace_Id = :traceId
            """;

        return jdbcClient.sql(sql)
                .param("traceId", traceId)
                .query((rs, rowNum) -> PaymentWebhookLog.builder()
                        .id(rs.getLong("Id"))
                        .provider(PaymentProvider.valueOf(rs.getString("Provider")))
                        .orderNo(rs.getString("Order_No"))
                        .requestPayload(rs.getString("Request_Payload"))
                        .responsePayload(rs.getString("Response_Payload"))
                        .signature(rs.getString("Signature"))
                        .status(rs.getString("Status"))
                        .traceId(rs.getString("Trace_Id"))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .build())
                .optional();
    }
}
