package com.bmf.mobile.app.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Phản hồi chuỗi và ảnh QR Code MMQR động EMVCo.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MmqrResponse {

    private String orderNo;
    private String loanCode;
    private Long scheduleId;
    private BigDecimal amount;
    private String currency;
    private String mmqrString;
    private String qrImageBase64;
    private LocalDateTime expiredTime;
    private String merchantName;
    private String billReference;
}
