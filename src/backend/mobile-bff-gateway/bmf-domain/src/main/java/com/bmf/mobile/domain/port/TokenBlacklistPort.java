package com.bmf.mobile.domain.port;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;

/**
 * Cổng giao tiếp quản lý Redis Token Blacklist, Refresh Token Session và bẫy Brute-force PIN (Domain Port).
 */
public interface TokenBlacklistPort {

    /**
     * Đưa Access Token JTI vào Blacklist trên Redis với thời gian hết hạn TTL.
     */
    void blacklistToken(String jti, long remainingSeconds);

    /**
     * Kiểm tra xem Access Token JTI có nằm trong Blacklist hay không.
     */
    boolean isBlacklisted(String jti);

    /**
     * Lưu trữ thông tin phiên làm việc của Refresh Token trên Redis.
     */
    void storeRefreshToken(String refreshToken, String userId, UserType userType, String deviceId, PlatformType platform);

    /**
     * Lấy thông tin phiên làm việc từ Refresh Token trên Redis.
     */
    RefreshTokenData getRefreshTokenData(String refreshToken);

    /**
     * Thu hồi (hủy) Refresh Token khỏi Redis.
     */
    void revokeRefreshToken(String refreshToken);

    /**
     * Kiểm tra số thẻ NRC của khách hàng có đang bị khóa do nhập sai PIN quá 5 lần không.
     */
    boolean isPinLocked(String nrc);

    /**
     * Ghi nhận 1 lần nhập sai mã PIN và trả về tổng số lần sai hiện tại trong cửa sổ trượt.
     */
    long recordPinFailure(String nrc);

    /**
     * Xóa bộ đếm sai mã PIN khi khách hàng nhập đúng mã PIN.
     */
    void resetPinFailure(String nrc);
}
