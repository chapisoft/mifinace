package com.bmf.mobile.domain.port;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;

/**
 * Cổng giao tiếp cấp phát và trích xuất JWT Token (Domain Port).
 */
public interface TokenProviderPort {

    /**
     * Tạo Access Token với đầy đủ Claims.
     */
    String generateAccessToken(String userId, UserType userType, String deviceId, PlatformType platform);

    /**
     * Tạo Refresh Token ngẫu nhiên có độ dài bảo mật cao.
     */
    String generateRefreshToken();

    /**
     * Kiểm tra tính hợp lệ và chữ ký số của Access Token.
     */
    boolean validateToken(String token);

    /**
     * Trích xuất JWT ID (jti) từ Access Token.
     */
    String extractJti(String token);

    /**
     * Trích xuất User ID (Subject) từ Access Token.
     */
    String extractUserId(String token);

    /**
     * Trích xuất thời gian sống còn lại (giây) của Access Token.
     */
    long getRemainingTtlSeconds(String token);

    /**
     * Lấy thời gian hết hạn của Access Token (giây).
     */
    long getAccessTokenExpirationSeconds();

    /**
     * Lấy thời gian hết hạn của Refresh Token (giây).
     */
    long getRefreshTokenExpirationSeconds();
}
