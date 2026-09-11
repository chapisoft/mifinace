package com.bmf.mobile.domain.enums;

/**
 * Trạng thái của sự kiện Outbox Pattern trong bảng SYS_OUTBOX_EVENT.
 */
public enum OutboxStatus {
    /**
     * Đang chờ tiến trình ngầm xử lý đồng bộ.
     */
    PENDING,

    /**
     * Đang được một tiến trình ngầm tiếp nhận xử lý.
     */
    PROCESSING,

    /**
     * Đã xử lý đồng bộ thành công vào Core NG-mFINA.
     */
    PROCESSED,

    /**
     * Đã gửi thông báo đẩy thành công đến thiết bị khách hàng qua FCM HTTP/2.
     */
    SENT,

    /**
     * Xử lý thất bại và đã vượt quá số lần thử lại tối đa.
     */
    FAILED
}
