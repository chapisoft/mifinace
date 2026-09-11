package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.DebtClassificationGroup;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Entity chi tiết từng kỳ trả nợ của khách hàng kèm 5 nhóm nợ chuẩn FRD Myanmar.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class CustomerLoanScheduleRecord {

    private Long scheduleId;
    private String loanCode;
    private Integer installmentNo;
    private LocalDate dueDate;
    private BigDecimal principalAmount;
    private BigDecimal interestAmount;
    private BigDecimal compulsorySavingAmount;
    private BigDecimal insuranceFee;
    private BigDecimal totalDueAmount;
    private BigDecimal paidAmount;
    private RepaymentStatus status;
    private Integer overdueDays;
    private DebtClassificationGroup debtGroup;
}
