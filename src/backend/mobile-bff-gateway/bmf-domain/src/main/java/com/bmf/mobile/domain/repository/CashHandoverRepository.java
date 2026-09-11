package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.CashHandover;
import com.bmf.mobile.domain.enums.CashHandoverStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp dữ liệu bàn giao quỹ tiền mặt (Domain Repository Port).
 */
public interface CashHandoverRepository {
    void save(CashHandover handover);
    Optional<CashHandover> findById(String handoverId);
    List<CashHandover> findByCollectorId(String collectorId);
    void updateStatus(String handoverId, CashHandoverStatus status, String confirmedBy);
    BigDecimal calculateTotalCashCollectedToday(String collectorId, LocalDate date);
    int countTotalTransactionsToday(String collectorId, LocalDate date);
}
