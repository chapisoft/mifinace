package com.bmf.mobile.app.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

/**
 * Phản hồi chi tiết lịch trả nợ toàn khóa của hợp đồng vay vốn khách hàng kèm 5 nhóm nợ FRD.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerLoanScheduleResponse {

    private String loanCode;
    private String customerCode;
    private String customerName;
    private BigDecimal totalPrincipal;
    private BigDecimal remainingPrincipal;
    private Integer totalInstallments;
    private Integer paidInstallments;
    private Integer maxOverdueDays;
    private String currentDebtGroup;
    private String currentDebtGroupDescription;
    private List<CustomerLoanScheduleItemResponse> schedules;
}
