package com.bmf.mobile.domain.enums;

/**
 * Đơn vị cung cấp giải pháp thanh toán số và ví điện tử Myanmar.
 */
public enum PaymentProvider {
    KBZPAY("KBZPay (KBZ Bank)"),
    WAVEPAY("WavePay (Wave Money)"),
    AYAPAY("AYA Pay (AYA Bank)"),
    MYTELPAY("MytelPay"),
    CB_PAY("CB Pay (CB Bank)"),
    MMQR("Myanmar National Standard QR (CBM)");

    private final String description;

    PaymentProvider(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
