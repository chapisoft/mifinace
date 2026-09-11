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
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

/**
 * Triển khai OutboxEventRepository truy xuất bảng SYS_OUTBOX_EVENT trên SQL Server kèm memory fallback.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcOutboxEventRepository implements OutboxEventRepository {

    private final JdbcClient jdbcClient;
    private final Map<Long, OutboxEvent> memoryStore = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1000);

    @Override
    public OutboxEvent save(OutboxEvent event) {
        if (event.getEventId() == null) {
            event.setEventId(idGenerator.incrementAndGet());
        }
        if (event.getCreatedTime() == null) {
            event.setCreatedTime(LocalDateTime.now());
        }
        if (event.getStatus() == null) {
            event.setStatus(OutboxStatus.PENDING);
        }
        if (event.getMaxRetries() <= 0) {
            event.setMaxRetries(5);
        }

        memoryStore.put(event.getEventId(), event);

        try {
            String sql = """
                INSERT INTO dbo.SYS_OUTBOX_EVENT (Aggregate_Type, Aggregate_ID, Event_Type, Payload_JSON,
                                                  Status, Retry_Count, Max_Retries, Created_Time)
                VALUES (:aggregateType, :aggregateId, :eventType, :payloadJson,
                        :status, :retryCount, :maxRetries, :createdTime)
                """;

            jdbcClient.sql(sql)
                    .param("aggregateType", event.getAggregateType())
                    .param("aggregateId", event.getAggregateId())
                    .param("eventType", event.getEventType())
                    .param("payloadJson", event.getPayloadJson())
                    .param("status", event.getStatus().name())
                    .param("retryCount", event.getRetryCount())
                    .param("maxRetries", event.getMaxRetries())
                    .param("createdTime", Timestamp.valueOf(event.getCreatedTime()))
                    .update();

            log.info("Saved Outbox event to database: eventId={}, aggregateType={}, aggregateId={}, eventType={}",
                    event.getEventId(), event.getAggregateType(), event.getAggregateId(), event.getEventType());
        } catch (Exception e) {
            log.warn("Database unavailable, saved Outbox event to in-memory store: eventId={}, aggregateId={}, error={}",
                    event.getEventId(), event.getAggregateId(), e.getMessage());
        }
        return event;
    }

    @Override
    public List<OutboxEvent> findPendingEvents(int limit) {
        try {
            String sql = """
                SELECT TOP (:limit) Event_ID, Aggregate_Type, Aggregate_ID, Event_Type, Payload_JSON,
                                    Status, Retry_Count, Max_Retries, Error_Message, Created_Time,
                                    Processed_Time, Sent_Time
                FROM dbo.SYS_OUTBOX_EVENT WITH (READPAST)
                WHERE Status = 'PENDING' AND Retry_Count < Max_Retries
                ORDER BY Event_ID ASC
                """;

            List<OutboxEvent> list = jdbcClient.sql(sql)
                    .param("limit", limit)
                    .query(this::mapRowToOutboxEvent)
                    .list();
            if (!list.isEmpty()) {
                return list;
            }
        } catch (Exception e) {
            log.debug("Querying pending Outbox events from memory fallback: {}", e.getMessage());
        }

        return memoryStore.values().stream()
                .filter(e -> e.getStatus() == OutboxStatus.PENDING && e.getRetryCount() < e.getMaxRetries())
                .sorted((a, b) -> Long.compare(a.getEventId(), b.getEventId()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    @Override
    public void updateStatus(Long eventId, OutboxStatus status, String errorMessage) {
        OutboxEvent event = memoryStore.get(eventId);
        if (event != null) {
            event.setStatus(status);
            event.setErrorMessage(errorMessage);
            event.setProcessedTime(LocalDateTime.now());
            if (status == OutboxStatus.SENT || status == OutboxStatus.PROCESSED) {
                event.setSentTime(LocalDateTime.now());
            } else if (status == OutboxStatus.FAILED) {
                event.setRetryCount(event.getRetryCount() + 1);
            }
        }

        try {
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
        } catch (Exception e) {
            log.debug("Database unavailable, updated Outbox event status in memory: eventId={}, status={}", eventId, status);
        }
    }

    @Override
    public Optional<OutboxEvent> findById(Long eventId) {
        try {
            String sql = "SELECT * FROM dbo.SYS_OUTBOX_EVENT WHERE Event_ID = :eventId";
            return jdbcClient.sql(sql)
                    .param("eventId", eventId)
                    .query(this::mapRowToOutboxEvent)
                    .optional();
        } catch (Exception e) {
            return Optional.ofNullable(memoryStore.get(eventId));
        }
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
