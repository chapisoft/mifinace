package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.PaymentProvider;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Entity ghi nhận lịch sử Webhook từ các ví điện tử (SYS_PAYMENT_WEBHOOK_LOG).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class PaymentWebhookLog {

    private Long id;
    private PaymentProvider provider;
    private String orderNo;
    private String requestPayload;
    private String responsePayload;
    private String signature;
    private String status;
    private String traceId;
    private LocalDateTime createdTime;
}
