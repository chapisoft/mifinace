package com.bmf.mobile.domain.enums;

/**
 * Trạng thái của yêu cầu thanh toán số qua MMQR / Ví điện tử.
 */
public enum PaymentOrderStatus {
    PENDING("Chờ thanh toán"),
    SETTLED("Đã gạch nợ thành công"),
    EXPIRED("Hết hạn thanh toán"),
    FAILED("Thanh toán thất bại"),
    CANCELLED("Đã hủy bỏ");

    private final String description;

    PaymentOrderStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
