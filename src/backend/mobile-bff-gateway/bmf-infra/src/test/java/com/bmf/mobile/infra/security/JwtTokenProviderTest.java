package com.bmf.mobile.infra.security;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JwtTokenProviderTest {

    private JwtTokenProvider jwtTokenProvider;
    private JwtProperties jwtProperties;

    @BeforeEach
    void setUp() {
        jwtProperties = new JwtProperties();
        jwtProperties.setSecret("BMF_MYANMAR_SUPER_SECRET_KEY_2026_MICROFINANCE_PLATFORM_KEY_256_BITS!");
        jwtProperties.setAccessTokenExpirationSeconds(900);
        jwtProperties.setRefreshTokenExpirationSeconds(2592000);
        jwtProperties.setIssuer("BMF-Gateway-Test");

        jwtTokenProvider = new JwtTokenProvider(jwtProperties);
        jwtTokenProvider.init();
    }

    @Test
    @DisplayName("Sinh và xác thực Access Token JWT với đầy đủ Claims")
    void generateAndValidateAccessTokenSuccess() {
        String token = jwtTokenProvider.generateAccessToken(
                "USR001", UserType.AGENT, "DEV-001", PlatformType.ANDROID);

        assertNotNull(token);
        assertTrue(jwtTokenProvider.validateToken(token));

        Claims claims = jwtTokenProvider.extractClaims(token);
        assertEquals("USR001", claims.getSubject());
        assertEquals("AGENT", claims.get("userType"));
        assertEquals("DEV-001", claims.get("deviceId"));
        assertEquals("ANDROID", claims.get("platform"));
        assertEquals("BMF-Gateway-Test", claims.getIssuer());
        assertNotNull(claims.getId());

        assertEquals("USR001", jwtTokenProvider.extractUserId(token));
        assertEquals(claims.getId(), jwtTokenProvider.extractJti(token));
        assertTrue(jwtTokenProvider.getRemainingTtlSeconds(token) > 0);
    }

    @Test
    @DisplayName("Kiểm tra Token không hợp lệ (sai chữ ký hoặc chuỗi rác)")
    void validateInvalidTokenShouldReturnFalse() {
        assertFalse(jwtTokenProvider.validateToken("invalid.token.signature"));
        assertFalse(jwtTokenProvider.validateToken(""));
        assertFalse(jwtTokenProvider.validateToken(null));
    }

    @Test
    @DisplayName("Sinh Refresh Token ngẫu nhiên không có dấu gạch ngang")
    void generateRefreshTokenShouldBeRandomAlphanumeric() {
        String refreshToken1 = jwtTokenProvider.generateRefreshToken();
        String refreshToken2 = jwtTokenProvider.generateRefreshToken();

        assertNotNull(refreshToken1);
        assertNotNull(refreshToken2);
        assertFalse(refreshToken1.contains("-"));
        assertFalse(refreshToken2.contains("-"));
        assertEquals(32, refreshToken1.length());
    }
}
