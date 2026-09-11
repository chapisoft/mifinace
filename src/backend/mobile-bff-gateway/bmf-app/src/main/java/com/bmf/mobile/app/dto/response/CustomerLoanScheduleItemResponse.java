package com.bmf.mobile.app.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Chi tiết từng kỳ trong lịch trả nợ toàn khóa của khách hàng.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerLoanScheduleItemResponse {

    private Long scheduleId;
    private Integer installmentNo;
    private LocalDate dueDate;
    private BigDecimal principalAmount;
    private BigDecimal interestAmount;
    private BigDecimal compulsorySavingAmount;
    private BigDecimal insuranceFee;
    private BigDecimal totalDueAmount;
    private BigDecimal paidAmount;
    private String status;
    private Integer overdueDays;
    private String debtGroup;
    private String debtGroupDescription;
}
