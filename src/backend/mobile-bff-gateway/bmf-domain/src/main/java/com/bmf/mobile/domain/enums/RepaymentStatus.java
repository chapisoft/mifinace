package com.bmf.mobile.domain.enums;

/**
 * Trạng thái của giao dịch thu nợ tín dụng vi mô.
 */
public enum RepaymentStatus {
    /**
     * Đang chờ xử lý đồng bộ.
     */
    PENDING,

    /**
     * Cán bộ tín dụng đã thu tiền tại thực địa thành công (biên lai offline/online đã cấp).
     */
    COLLECTED,

    /**
     * Đã gạch nợ và quyết toán hoàn tất vào CSDL Core NG-mFINA.
     */
    SETTLED,

    /**
     * Giao dịch thất bại (lỗi kiểm tra đối soát hoặc dữ liệu không hợp lệ).
     */
    FAILED,

    /**
     * Giao dịch đã bị hủy bỏ bởi kiểm soát viên.
     */
    CANCELLED
}
