package com.bmf.mobile.domain.enums;

/**
 * Phân loại loại sự kiện Outbox Pattern trong bảng SYS_OUTBOX_EVENT.
 */
public enum OutboxEventType {
    /**
     * Sự kiện giải ngân vốn vay cho khách hàng thành viên.
     */
    LOAN_DISBURSED,

    /**
     * Sự kiện thu nợ thành công (tại quầy, thực địa hoặc qua ví điện tử).
     */
    PAYMENT_RECEIVED,

    /**
     * Sự kiện thu nợ từ cán bộ thực địa (đồng bộ quyết toán).
     */
    REPAYMENT_COLLECTED,

    /**
     * Sự kiện nộp tiền gửi vào sổ tiết kiệm tích lũy / bắt buộc.
     */
    SAVING_DEPOSITED,

    /**
     * Sự kiện rút tiền từ sổ tiết kiệm.
     */
    SAVING_WITHDRAWN,

    /**
     * Sự kiện nhắc nợ tự động đến hạn (chạy vào 08:00 AM hàng ngày).
     */
    LOAN_DUE_REMINDER
}
