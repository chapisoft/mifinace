package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Triển khai OutboxEventRepository truy xuất bảng SYS_OUTBOX_EVENT trên SQL Server kèm memory fallback.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcOutboxEventRepository implements OutboxEventRepository {

    private final JdbcClient jdbcClient;

    @Override
    public OutboxEvent save(OutboxEvent event) {
        if (event.getCreatedTime() == null) {
            event.setCreatedTime(LocalDateTime.now());
        }
        if (event.getStatus() == null) {
            event.setStatus(OutboxStatus.PENDING);
        }
        if (event.getMaxRetries() <= 0) {
            event.setMaxRetries(5);
        }

        String sql = """
            INSERT INTO dbo.SYS_OUTBOX_EVENT (Aggregate_Type, Aggregate_ID, Event_Type, Payload_JSON,
                                              Status, Retry_Count, Max_Retries, Created_Time)
            VALUES (:aggregateType, :aggregateId, :eventType, :payloadJson,
                    :status, :retryCount, :maxRetries, :createdTime)
            """;

        org.springframework.jdbc.support.GeneratedKeyHolder keyHolder = new org.springframework.jdbc.support.GeneratedKeyHolder();

        jdbcClient.sql(sql)
                .param("aggregateType", event.getAggregateType())
                .param("aggregateId", event.getAggregateId())
                .param("eventType", event.getEventType())
                .param("payloadJson", event.getPayloadJson())
                .param("status", event.getStatus().name())
                .param("retryCount", event.getRetryCount())
                .param("maxRetries", event.getMaxRetries())
                .param("createdTime", Timestamp.valueOf(event.getCreatedTime()))
                .update(keyHolder);

        Map<String, Object> keys = keyHolder.getKeys();
        if (keys != null) {
            Object idObj = keys.get("EVENT_ID");
            if (idObj == null) {
                idObj = keys.get("Event_ID");
            }
            if (idObj instanceof Number num) {
                event.setEventId(num.longValue());
            }
        } else {
            Number singleKey = keyHolder.getKey();
            if (singleKey != null) {
                event.setEventId(singleKey.longValue());
            }
        }

        log.info("Saved Outbox event to database: eventId={}, aggregateType={}, aggregateId={}, eventType={}",
                event.getEventId(), event.getAggregateType(), event.getAggregateId(), event.getEventType());
        return event;
    }

    @Override
    public List<OutboxEvent> findPendingEvents(int limit) {
        String sql = """
            SELECT TOP (:limit) Event_ID, Aggregate_Type, Aggregate_ID, Event_Type, Payload_JSON,
                                Status, Retry_Count, Max_Retries, Error_Message, Created_Time,
                                Processed_Time, Sent_Time
            FROM dbo.SYS_OUTBOX_EVENT
            WHERE Status = 'PENDING' AND Retry_Count < Max_Retries
            ORDER BY Event_ID ASC
            """;

        return jdbcClient.sql(sql)
                .param("limit", limit)
                .query(this::mapRowToOutboxEvent)
                .list();
    }

    @Override
    public void updateStatus(Long eventId, OutboxStatus status, String errorMessage) {
        String sql = """
            UPDATE dbo.SYS_OUTBOX_EVENT
            SET Status = :status,
                Error_Message = :errorMessage,
                Processed_Time = :processedTime,
                Sent_Time = CASE WHEN :status IN ('SENT', 'PROCESSED') THEN :processedTime ELSE Sent_Time END,
                Retry_Count = CASE WHEN :status = 'FAILED' THEN Retry_Count + 1 ELSE Retry_Count END
            WHERE Event_ID = :eventId
            """;

        jdbcClient.sql(sql)
                .param("status", status.name())
                .param("errorMessage", errorMessage)
                .param("processedTime", Timestamp.valueOf(LocalDateTime.now()))
                .param("eventId", eventId)
                .update();

        log.info("Updated Outbox event status in database: eventId={}, status={}", eventId, status);
    }

    @Override
    public Optional<OutboxEvent> findById(Long eventId) {
        String sql = "SELECT * FROM dbo.SYS_OUTBOX_EVENT WHERE Event_ID = :eventId";
        return jdbcClient.sql(sql)
                .param("eventId", eventId)
                .query(this::mapRowToOutboxEvent)
                .optional();
    }

    private OutboxEvent mapRowToOutboxEvent(java.sql.ResultSet rs, int rowNum) throws java.sql.SQLException {
        return OutboxEvent.builder()
                .eventId(rs.getLong("Event_ID"))
                .aggregateType(rs.getString("Aggregate_Type"))
                .aggregateId(rs.getString("Aggregate_ID"))
                .eventType(rs.getString("Event_Type"))
                .payloadJson(rs.getString("Payload_JSON"))
                .status(OutboxStatus.valueOf(rs.getString("Status")))
                .retryCount(rs.getInt("Retry_Count"))
                .maxRetries(rs.getInt("Max_Retries"))
                .errorMessage(rs.getString("Error_Message"))
                .createdTime(rs.getTimestamp("Created_Time") != null ? rs.getTimestamp("Created_Time").toLocalDateTime() : null)
                .processedTime(rs.getTimestamp("Processed_Time") != null ? rs.getTimestamp("Processed_Time").toLocalDateTime() : null)
                .sentTime(rs.getTimestamp("Sent_Time") != null ? rs.getTimestamp("Sent_Time").toLocalDateTime() : null)
                .build();
    }
}
