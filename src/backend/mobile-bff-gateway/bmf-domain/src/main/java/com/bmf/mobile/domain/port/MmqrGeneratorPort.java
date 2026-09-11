package com.bmf.mobile.domain.port;

import java.math.BigDecimal;

/**
 * Cổng giao tiếp sinh chuỗi và ảnh QR Code chuẩn MMQR EMVCo CBM (Central Bank of Myanmar).
 */
public interface MmqrGeneratorPort {

    /**
     * Sinh chuỗi dữ liệu TLV chuẩn MMQR EMVCo.
     */
    String generateMmqrPayload(String merchantName, String merchantCity, String billReference, BigDecimal amount, String currency);

    /**
     * Sinh ảnh PNG Base64 từ chuỗi dữ liệu QR.
     */
    String generateQrCodeBase64(String payload, int width, int height);
}
