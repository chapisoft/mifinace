package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.OutboxStatus;

import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp truy xuất và cập nhật sự kiện Outbox Pattern trong bảng SYS_OUTBOX_EVENT (Domain Repository).
 */
public interface OutboxEventRepository {

    /**
     * Lưu sự kiện Outbox mới vào CSDL.
     */
    OutboxEvent save(OutboxEvent event);

    /**
     * Tìm danh sách các sự kiện đang ở trạng thái PENDING để tiến trình ngầm xử lý theo mẻ.
     */
    List<OutboxEvent> findPendingEvents(int limit);

    /**
     * Cập nhật trạng thái và thời gian xử lý sự kiện.
     */
    void updateStatus(Long eventId, OutboxStatus status, String errorMessage);

    /**
     * Tìm sự kiện theo Event ID.
     */
    Optional<OutboxEvent> findById(Long eventId);
}
