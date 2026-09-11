package com.bmf.mobile.domain.enums;

/**
 * Phương thức thanh toán thu nợ tín dụng vi mô tại Myanmar.
 */
public enum RepaymentMethod {
    /**
     * Tiền mặt (Cán bộ thu tại buổi họp Cụm/Tổ).
     */
    CASH,

    /**
     * Ví điện tử Wave Money (WavePay).
     */
    WAVE_PAY,

    /**
     * Ví điện tử KBZPay.
     */
    KBZ_PAY,

    /**
     * Ví điện tử AYA Pay.
     */
    AYA_PAY,

    /**
     * Ví điện tử MytelPay.
     */
    MYTEL_PAY,

    /**
     * Mã QR quốc gia MMQR (CBM).
     */
    MMQR,

    /**
     * Chuyển khoản ngân hàng (AYA, CB, KBZ Bank).
     */
    BANK_TRANSFER
}
