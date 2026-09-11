package com.bmf.mobile.infra.payment;

import com.bmf.mobile.domain.port.MmqrGeneratorPort;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * Hiện thực sinh chuỗi dữ liệu TLV chuẩn MMQR EMVCo CBM và ảnh QR Code Base64.
 */
@Slf4j
@Service
public class MmqrGeneratorService implements MmqrGeneratorPort {

    private static final String PAYLOAD_FORMAT_INDICATOR = "000201";
    private static final String DYNAMIC_QR_INIT_METHOD = "010212";
    private static final String MERCHANT_CATEGORY_CODE = "52046012";
    private static final String CURRENCY_MMK_CODE = "5303104"; // ISO 4217 code for MMK
    private static final String COUNTRY_CODE_MYANMAR = "5802MM";

    @Override
    public String generateMmqrPayload(String merchantName, String merchantCity, String billReference, BigDecimal amount, String currency) {
        StringBuilder sb = new StringBuilder();
        sb.append(PAYLOAD_FORMAT_INDICATOR);
        sb.append(DYNAMIC_QR_INIT_METHOD);

        // Tag 26: Merchant Account Information
        String guidTag = formatTlv("00", "mm.gov.cbm.mmqr");
        String merchantIdTag = formatTlv("01", "BMF_MICROFINANCE");
        String billRefSubTag = formatTlv("02", billReference != null ? billReference : "BMF_LOAN");
        String tag26Value = guidTag + merchantIdTag + billRefSubTag;
        sb.append(formatTlv("26", tag26Value));

        // Tag 52: MCC
        sb.append(MERCHANT_CATEGORY_CODE);

        // Tag 53: Currency (104 for MMK)
        sb.append(CURRENCY_MMK_CODE);

        // Tag 54: Amount
        if (amount != null && amount.compareTo(BigDecimal.ZERO) > 0) {
            String formattedAmount = String.format("%.2f", amount);
            sb.append(formatTlv("54", formattedAmount));
        }

        // Tag 58: Country Code
        sb.append(COUNTRY_CODE_MYANMAR);

        // Tag 59: Merchant Name
        String cleanMerchantName = (merchantName != null && !merchantName.isBlank()) ? merchantName : "BMF MICROFINANCE";
        sb.append(formatTlv("59", cleanMerchantName));

        // Tag 60: Merchant City
        String cleanCity = (merchantCity != null && !merchantCity.isBlank()) ? merchantCity : "YANGON";
        sb.append(formatTlv("60", cleanCity));

        // Tag 62: Additional Data (Bill Number)
        if (billReference != null && !billReference.isBlank()) {
            String billTag = formatTlv("01", billReference);
            sb.append(formatTlv("62", billTag));
        }

        // Tag 63: CRC-16-CCITT (Checksum)
        String rawWithoutCrc = sb.toString() + "6304";
        String crcHex = calculateCrc16Ccitt(rawWithoutCrc);
        String finalPayload = rawWithoutCrc + crcHex;

        log.info("Generated MMQR EMVCo payload: billRef={}, amount={}, length={}",
                billReference, amount, finalPayload.length());
        return finalPayload;
    }

    @Override
    public String generateQrCodeBase64(String payload, int width, int height) {
        try {
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, StandardCharsets.UTF_8.name());
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
            hints.put(EncodeHintType.MARGIN, 2);

            BitMatrix bitMatrix = qrCodeWriter.encode(payload, BarcodeFormat.QR_CODE, width, height, hints);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
            byte[] imageBytes = outputStream.toByteArray();

            return "data:image/png;base64," + Base64.getEncoder().encodeToString(imageBytes);
        } catch (Exception e) {
            log.error("Failed to generate QR Code Base64 image: error={}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate QR Code image", e);
        }
    }

    private String formatTlv(String tag, String value) {
        if (value == null) {
            value = "";
        }
        int length = value.getBytes(StandardCharsets.UTF_8).length;
        return String.format("%s%02d%s", tag, length, value);
    }

    private String calculateCrc16Ccitt(String data) {
        int crc = 0xFFFF; // initial value
        int polynomial = 0x1021; // 0001 0000 0010 0001 (0, 5, 12)

        byte[] bytes = data.getBytes(StandardCharsets.UTF_8);
        for (byte b : bytes) {
            for (int i = 0; i < 8; i++) {
                boolean bit = ((b >> (7 - i) & 1) == 1);
                boolean c15 = ((crc >> 15 & 1) == 1);
                crc <<= 1;
                if (c15 ^ bit) {
                    crc ^= polynomial;
                }
            }
        }
        crc &= 0xFFFF;
        return String.format("%04X", crc);
    }
}
