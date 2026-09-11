package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.RepaymentTransaction;

import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp truy xuất và lưu trữ giao dịch thu nợ tín dụng vi mô (Domain Repository).
 */
public interface RepaymentRepository {

    /**
     * Lưu thông tin giao dịch thu nợ.
     */
    RepaymentTransaction save(RepaymentTransaction transaction);

    /**
     * Tìm giao dịch theo mã giao dịch duy nhất.
     */
    Optional<RepaymentTransaction> findById(String transactionId);

    /**
     * Tìm giao dịch theo khóa chống trùng lặp Idempotency Key.
     */
    Optional<RepaymentTransaction> findByIdempotencyKey(String idempotencyKey);

    /**
     * Tìm danh sách giao dịch thu nợ của một hợp đồng theo kỳ.
     */
    List<RepaymentTransaction> findByContractCodeAndPeriod(String contractCode, int periodNumber);

    /**
     * Lấy danh sách giao dịch thu nợ do cán bộ thực hiện trong ngày.
     */
    List<RepaymentTransaction> findByCollectedByAndDate(String collectedBy, String date);
}
