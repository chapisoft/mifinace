package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.CashHandoverStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Thực thể biên bản bàn giao quỹ tiền mặt lưu động cuối ngày.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CashHandover {
    private String handoverId;
    private String collectorId;
    private LocalDate handoverDate;
    private BigDecimal totalAmount;
    private Integer totalTransactions;
    private String qrPayload;
    private String qrSignature;
    private CashHandoverStatus status;
    private LocalDateTime createdTime;
    private String confirmedBy;
    private LocalDateTime confirmedTime;
}
