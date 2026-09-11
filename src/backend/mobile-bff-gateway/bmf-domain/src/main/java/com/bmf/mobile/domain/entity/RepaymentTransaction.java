package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity đại diện cho giao dịch thu nợ tín dụng vi mô (Online & Offline).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RepaymentTransaction {

    /**
     * Mã giao dịch duy nhất (UUIDv4).
     */
    private String transactionId;

    /**
     * Mã hợp đồng tín dụng (Ma_HD).
     */
    private String contractCode;

    /**
     * Mã khách hàng thành viên (Ma_TV).
     */
    private String customerCode;

    /**
     * Tên khách hàng thành viên.
     */
    private String customerName;

    /**
     * Mã Cụm/Tổ (Ma_Cum_To).
     */
    private String groupCode;

    /**
     * Kỳ thu nợ (Ky_Thu).
     */
    private int periodNumber;

    /**
     * Số tiền gốc đã thu (Ky_Goc).
     */
    private BigDecimal principalAmount;

    /**
     * Số tiền lãi đã thu (Ky_Lai).
     */
    private BigDecimal interestAmount;

    /**
     * Phí bảo hiểm vi mô (Phi_BH).
     */
    private BigDecimal insuranceFee;

    /**
     * Tiết kiệm bắt buộc (TietKiem_BatBuoc).
     */
    private BigDecimal compulsorySaving;

    /**
     * Tiền phạt quá hạn (nếu có).
     */
    private BigDecimal penaltyAmount;

    /**
     * Tổng số tiền thu thực tế.
     */
    private BigDecimal totalAmount;

    /**
     * Phương thức thanh toán (CASH, WAVE_PAY, KBZ_PAY, BANK_TRANSFER).
     */
    private RepaymentMethod paymentMethod;

    /**
     * Khóa chống trùng lặp giao dịch (Idempotency Key - UUIDv4 từ Mobile Client).
     */
    private String idempotencyKey;

    /**
     * Cán bộ tín dụng thực hiện thu tiền (User ID).
     */
    private String collectedBy;

    /**
     * Thời điểm cán bộ thực hiện thu tiền tại thực địa (Client Offline Timestamp).
     */
    private LocalDateTime collectedTime;

    /**
     * Thời điểm giao dịch được đẩy lên hệ thống Gateway đồng bộ.
     */
    private LocalDateTime syncedTime;

    /**
     * Trạng thái giao dịch (PENDING, COLLECTED, SETTLED, FAILED).
     */
    private RepaymentStatus status;

    /**
     * Ghi chú thu tiền hoặc lý do thất bại.
     */
    private String notes;
}
