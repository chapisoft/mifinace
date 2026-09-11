package com.bmf.mobile.domain.enums;

/**
 * Loại sản phẩm tiết kiệm tài chính vi mô.
 */
public enum SavingProductType {
    COMPULSORY,    // Tiết kiệm bắt buộc theo nhóm vay vốn
    VOLUNTARY,     // Tiết kiệm tự nguyện không kỳ hạn
    ACCUMULATIVE,  // Tiết kiệm gửi góp tích lũy
    FIXED_TERM     // Tiết kiệm có kỳ hạn cố định (3, 6, 12 tháng)
}
