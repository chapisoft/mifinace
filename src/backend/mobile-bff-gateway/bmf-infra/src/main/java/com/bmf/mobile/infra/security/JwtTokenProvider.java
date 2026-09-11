package com.bmf.mobile.infra.security;

import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.TokenProviderPort;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

/**
 * Quản lý sinh, ký số và xác thực Token JWT theo chuẩn JJWT 0.12+ (Triển khai TokenProviderPort).
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtTokenProvider implements TokenProviderPort {

    private final JwtProperties jwtProperties;
    private SecretKey secretKey;

    @PostConstruct
    public void init() {
        byte[] keyBytes = jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8);
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
    }

    @Override
    public String generateAccessToken(String userId, UserType userType, String deviceId, PlatformType platform) {
        String jti = UUID.randomUUID().toString();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + (jwtProperties.getAccessTokenExpirationSeconds() * 1000));

        return Jwts.builder()
                .header().type("JWT").and()
                .subject(userId)
                .id(jti)
                .issuer(jwtProperties.getIssuer())
                .issuedAt(now)
                .expiration(expiryDate)
                .claim("userType", userType.name())
                .claim("deviceId", deviceId)
                .claim("platform", platform != null ? platform.name() : null)
                .signWith(secretKey, Jwts.SIG.HS256)
                .compact();
    }

    @Override
    public String generateRefreshToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    @Override
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Token validation failed: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public String extractJti(String token) {
        return extractClaims(token).getId();
    }

    @Override
    public String extractUserId(String token) {
        return extractClaims(token).getSubject();
    }

    @Override
    public long getRemainingTtlSeconds(String token) {
        Claims claims = extractClaims(token);
        return getRemainingTtlSeconds(claims);
    }

    @Override
    public long getAccessTokenExpirationSeconds() {
        return jwtProperties.getAccessTokenExpirationSeconds();
    }

    @Override
    public long getRefreshTokenExpirationSeconds() {
        return jwtProperties.getRefreshTokenExpirationSeconds();
    }

    /**
     * Trích xuất toàn bộ Claims từ Access Token.
     */
    public Claims extractClaims(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            log.warn("JWT Token has expired: {}", e.getMessage());
            throw new BusinessException(ErrorCode.ERR_TOKEN_EXPIRED);
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT signature/format: {}", e.getMessage());
            throw new BusinessException(ErrorCode.ERR_TOKEN_INVALID);
        }
    }

    /**
     * Lấy thời gian sống còn lại của Token tính theo giây từ Claims.
     */
    public long getRemainingTtlSeconds(Claims claims) {
        Date expiration = claims.getExpiration();
        long now = System.currentTimeMillis();
        long remainingMillis = expiration.getTime() - now;
        return Math.max(0, remainingMillis / 1000);
    }
}
