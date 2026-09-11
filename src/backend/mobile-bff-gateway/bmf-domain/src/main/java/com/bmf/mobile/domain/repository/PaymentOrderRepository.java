package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.PaymentOrder;
import com.bmf.mobile.domain.enums.PaymentOrderStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp dữ liệu đơn hàng / yêu cầu thanh toán số (Domain Repository Port).
 */
public interface PaymentOrderRepository {

    void save(PaymentOrder order);

    Optional<PaymentOrder> findByOrderNo(String orderNo);

    Optional<PaymentOrder> findByLoanCodeAndScheduleId(String loanCode, Long scheduleId);

    void updateStatus(String orderNo, PaymentOrderStatus status, String partnerRefNo, LocalDateTime settledTime);

    List<PaymentOrder> findPendingOrdersByLoanCode(String loanCode);
}
