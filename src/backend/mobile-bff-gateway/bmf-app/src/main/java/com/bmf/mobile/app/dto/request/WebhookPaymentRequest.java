package com.bmf.mobile.app.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Payload tiếp nhận Webhook gạch nợ tự động từ đối tác ví điện tử (KBZPay, WavePay, AYA Pay, MytelPay).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebhookPaymentRequest {

    @NotBlank(message = "{validation.order.no.required}")
    private String orderNo;

    @NotBlank(message = "{validation.partner.ref.required}")
    private String partnerRefNo;

    @NotNull(message = "{validation.amount.required}")
    @Positive(message = "{validation.amount.positive}")
    private BigDecimal amount;

    private String currency;

    private String timestamp;

    private String signature;

    private String partnerStatus;
}
