package com.bmf.mobile.app.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

/**
 * Phản hồi tổng quan danh mục sổ tiết kiệm và tiền lãi dồn tích thực tế hàng ngày MMK của khách hàng.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerSavingOverviewResponse {

    private String customerCode;
    private BigDecimal totalSavingsBalance;
    private BigDecimal totalAccruedInterest;
    private Integer totalAccounts;
    private List<SavingAccountResponse> accounts;
}
