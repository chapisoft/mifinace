package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingProductType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Thực thể tài khoản sổ tiết kiệm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SavingAccount {
    private String accountNumber;
    private String customerCode;
    private String customerName;
    private SavingProductType productType;
    private BigDecimal balance;
    private BigDecimal interestRate;
    private Integer termMonths;
    private String beneficiaryName;
    private String beneficiaryNrc;
    private SavingAccountStatus status;
    private String createdBy;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}
