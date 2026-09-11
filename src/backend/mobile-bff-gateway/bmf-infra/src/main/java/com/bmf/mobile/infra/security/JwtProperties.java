package com.bmf.mobile.infra.security;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Cấu hình tham số bảo mật JWT.
 */
@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "security.jwt")
public class JwtProperties {

    /**
     * Khóa bí mật HMAC-SHA256 (tối thiểu 256 bits / 32 ký tự).
     */
    private String secret = "BMF_MYANMAR_SUPER_SECRET_KEY_2026_MICROFINANCE_PLATFORM_KEY_256_BITS!";

    /**
     * Thời gian sống của Access Token (Mặc định: 900s / 15 phút).
     */
    private long accessTokenExpirationSeconds = 900;

    /**
     * Thời gian sống của Refresh Token (Mặc định: 2592000s / 30 ngày).
     */
    private long refreshTokenExpirationSeconds = 2592000;

    /**
     * Tên đơn vị phát hành (Issuer).
     */
    private String issuer = "BMF-Gateway";
}
