package com.bmf.mobile.app.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Phản hồi cho cổng Webhook đối tác thanh toán.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebhookPaymentResponse {

    private String code;
    private String message;
    private String orderNo;
    private String partnerRefNo;
    private LocalDateTime settledTime;
}
