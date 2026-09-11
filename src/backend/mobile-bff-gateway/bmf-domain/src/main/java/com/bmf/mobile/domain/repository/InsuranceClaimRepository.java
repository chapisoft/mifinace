package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.InsuranceClaim;
import com.bmf.mobile.domain.enums.InsuranceClaimStatus;

import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp dữ liệu bảo hiểm tương hỗ (Domain Repository Port).
 */
public interface InsuranceClaimRepository {
    void save(InsuranceClaim claim);
    Optional<InsuranceClaim> findById(String claimId);
    List<InsuranceClaim> findByCustomerCode(String customerCode);
    void updateStatus(String claimId, InsuranceClaimStatus status, String approvedBy);
}
