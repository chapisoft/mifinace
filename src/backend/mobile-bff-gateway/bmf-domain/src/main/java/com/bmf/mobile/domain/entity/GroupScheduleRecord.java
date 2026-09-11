package com.bmf.mobile.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Bản ghi chi tiết lịch thu nợ Cụm/Tổ của từng thành viên trong kỳ.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroupScheduleRecord {

    private String contractCode;
    private String customerCode;
    private String customerName;
    private String groupCode;
    private int periodNumber;
    private BigDecimal principalAmount;
    private BigDecimal interestAmount;
    private BigDecimal insuranceFee;
    private BigDecimal compulsorySaving;
    private BigDecimal totalAmount;
    private LocalDate dueDate;
    private String status;
}
