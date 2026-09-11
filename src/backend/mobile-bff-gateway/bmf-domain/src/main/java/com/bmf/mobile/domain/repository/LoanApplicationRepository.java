package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.LoanApplication;
import com.bmf.mobile.domain.enums.LoanApplicationStatus;

import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp dữ liệu hồ sơ vay vốn thực địa (Domain Repository Port).
 */
public interface LoanApplicationRepository {
    void save(LoanApplication application);
    Optional<LoanApplication> findById(String applicationId);
    List<LoanApplication> findByCustomerCode(String customerCode);
    List<LoanApplication> findByGroupCode(String groupCode);
    void updateStatus(String applicationId, LoanApplicationStatus status);
}
