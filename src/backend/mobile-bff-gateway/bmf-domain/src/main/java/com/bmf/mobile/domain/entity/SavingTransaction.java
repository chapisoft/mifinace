package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.enums.SavingTransactionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Thực thể giao dịch gửi/thu tiền tiết kiệm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SavingTransaction {
    private String transactionId;
    private String accountNumber;
    private String customerCode;
    private BigDecimal amount;
    private SavingTransactionType transactionType;
    private RepaymentMethod paymentMethod;
    private String collectedBy;
    private String idempotencyKey;
    private LocalDateTime collectedTime;
    private RepaymentStatus status;
    private LocalDateTime createdTime;
}
