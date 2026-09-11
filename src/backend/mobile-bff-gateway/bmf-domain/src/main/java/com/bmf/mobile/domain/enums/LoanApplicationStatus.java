package com.bmf.mobile.domain.enums;

/**
 * Trạng thái hồ sơ vay vốn thực địa và thẩm định tín dụng.
 */
public enum LoanApplicationStatus {
    DRAFT,
    SUBMITTED,
    SCORING_PASSED,
    SCORING_REJECTED,
    APPROVED,
    REJECTED,
    DISBURSED
}
