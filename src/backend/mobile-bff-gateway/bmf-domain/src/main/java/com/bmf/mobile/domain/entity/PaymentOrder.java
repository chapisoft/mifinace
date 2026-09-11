package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.PaymentOrderStatus;
import com.bmf.mobile.domain.enums.PaymentProvider;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity đại diện cho Đơn hàng / Yêu cầu thanh toán số qua MMQR hoặc Ví điện tử (SYS_PAYMENT_ORDER).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class PaymentOrder {

    private Long id;
    private String orderNo;
    private String loanCode;
    private Long scheduleId;
    private BigDecimal amount;
    private String currency;
    private PaymentProvider provider;
    private PaymentOrderStatus status;
    private String mmqrPayload;
    private String partnerRefNo;
    private LocalDateTime expiredTime;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
    private LocalDateTime settledTime;
}
