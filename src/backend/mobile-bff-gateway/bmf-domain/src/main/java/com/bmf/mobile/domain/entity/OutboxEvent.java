package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.OutboxStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho sự kiện Outbox trong bảng SYS_OUTBOX_EVENT phục vụ Outbox Pattern.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OutboxEvent {

    /**
     * Mã sự kiện tự tăng (Event_ID).
     */
    private Long eventId;

    /**
     * Loại nghiệp vụ (Aggregate_Type: 'LOAN', 'SAVING', 'CUSTOMER').
     */
    private String aggregateType;

    /**
     * Khóa nghiệp vụ (Aggregate_ID: Mã hợp đồng, Mã khách hàng...).
     */
    private String aggregateId;

    /**
     * Loại sự kiện (Event_Type: 'REPAYMENT_COLLECTED', 'LOAN_DISBURSED'...).
     */
    private String eventType;

    /**
     * Dữ liệu chi tiết sự kiện dạng JSON Unicode (Payload_JSON).
     */
    private String payloadJson;

    /**
     * Trạng thái sự kiện (Status: PENDING, PROCESSING, PROCESSED, FAILED).
     */
    private OutboxStatus status;

    /**
     * Số lần đã thử gửi/xử lý lại (Retry_Count).
     */
    private int retryCount;

    /**
     * Số lần tối đa được phép thử lại (Max_Retries).
     */
    private int maxRetries;

    /**
     * Thông điệp lỗi nếu xử lý thất bại (Error_Message).
     */
    private String errorMessage;

    /**
     * Thời điểm phát sinh sự kiện (Created_Time).
     */
    private LocalDateTime createdTime;

    /**
     * Thời điểm bắt đầu xử lý (Processed_Time).
     */
    private LocalDateTime processedTime;

    /**
     * Thời điểm hoàn tất gửi thông báo / đồng bộ (Sent_Time).
     */
    private LocalDateTime sentTime;
}
