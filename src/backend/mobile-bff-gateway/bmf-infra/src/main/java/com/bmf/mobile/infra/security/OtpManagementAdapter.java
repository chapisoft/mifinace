package com.bmf.mobile.infra.security;

import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.OtpManagementPort;
import com.bmf.mobile.domain.port.StepUpTokenClaims;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RBucket;
import org.redisson.api.RedissonClient;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.Date;
import java.util.HexFormat;
import java.util.UUID;

/**
 * Hiện thực OtpManagementPort: Quản lý sinh OTP, xác thực băm OTP, cool-down và Step-Up Token bảo mật cao trên Redis.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OtpManagementAdapter implements OtpManagementPort {

    private final RedissonClient redissonClient;
    private final TokenBlacklistPort tokenBlacklistPort;
    private final JwtProperties jwtProperties;

    private static final String OTP_PREFIX = "BMF:SECURE_OTP:";
    private static final String COOLDOWN_PREFIX = "BMF:OTP_COOLDOWN:";
    private static final String OTP_SALT = "BMF_FINANCIAL_OTP_SALT_2026_";
    private static final int MAX_OTP_ATTEMPTS = 3;
    private static final long COOLDOWN_SECONDS = 60;
    private static final long STEP_UP_TOKEN_EXPIRATION_SECONDS = 600; // 10 phút

    private final SecureRandom secureRandom = new SecureRandom();
    private SecretKey secretKey;

    @PostConstruct
    public void init() {
        byte[] keyBytes = jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8);
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
    }

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OtpSessionData implements Serializable {
        private String otpHash;
        private int failedAttempts;
        private String phoneNumber;
        private long createdAtMillis;
    }

    private String hashOtp(String otpCode) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest((OTP_SALT + otpCode).getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new BusinessException(ErrorCode.ERR_INTERNAL_SERVER);
        }
    }

    @Override
    public String generateAndStoreOtp(String identifier, String purpose, String phoneNumber, int ttlSeconds) {
        if (isOtpCoolingDown(identifier, purpose)) {
            log.warn("OTP request rejected by cool-down: identifier={}, purpose={}", identifier, purpose);
            throw new BusinessException(ErrorCode.ERR_TOO_MANY_REQUESTS);
        }

        // Sinh 6 số ngẫu nhiên mật mã (100000 - 999999)
        int randomNum = 100000 + secureRandom.nextInt(900000);
        String otpCode = String.valueOf(randomNum);
        String otpHash = hashOtp(otpCode);

        String otpKey = OTP_PREFIX + purpose + ":" + identifier;
        OtpSessionData data = OtpSessionData.builder()
                .otpHash(otpHash)
                .failedAttempts(0)
                .phoneNumber(phoneNumber)
                .createdAtMillis(System.currentTimeMillis())
                .build();

        RBucket<OtpSessionData> bucket = redissonClient.getBucket(otpKey);
        bucket.set(data, Duration.ofSeconds(ttlSeconds));

        // Thiết lập Cool-down
        String cooldownKey = COOLDOWN_PREFIX + purpose + ":" + identifier;
        RBucket<String> cooldownBucket = redissonClient.getBucket(cooldownKey);
        cooldownBucket.set("ACTIVE", Duration.ofSeconds(COOLDOWN_SECONDS));

        log.info("Generated secure OTP: purpose={}, identifier={}, phone=***{}, ttl={}s",
                purpose, identifier, phoneNumber != null && phoneNumber.length() > 4 ? phoneNumber.substring(phoneNumber.length() - 4) : "xxxx", ttlSeconds);

        return otpCode;
    }

    @Override
    public boolean verifyOtp(String identifier, String purpose, String otpCode) {
        if (otpCode == null || otpCode.trim().length() != 6) {
            throw new BusinessException(ErrorCode.ERR_OTP_INVALID);
        }

        String otpKey = OTP_PREFIX + purpose + ":" + identifier;
        RBucket<OtpSessionData> bucket = redissonClient.getBucket(otpKey);
        OtpSessionData session = bucket.get();

        if (session == null) {
            log.warn("OTP verification failed - expired or not found: purpose={}, identifier={}", purpose, identifier);
            throw new BusinessException(ErrorCode.ERR_OTP_EXPIRED);
        }

        String incomingHash = hashOtp(otpCode.trim());
        if (!incomingHash.equalsIgnoreCase(session.getOtpHash())) {
            session.setFailedAttempts(session.getFailedAttempts() + 1);
            log.warn("OTP verification mismatch: purpose={}, identifier={}, attempt={}/{}",
                    purpose, identifier, session.getFailedAttempts(), MAX_OTP_ATTEMPTS);

            if (session.getFailedAttempts() >= MAX_OTP_ATTEMPTS) {
                bucket.delete();
                log.warn("OTP session terminated due to exceeding max attempts: identifier={}", identifier);
                throw new BusinessException(ErrorCode.ERR_OTP_EXPIRED);
            } else {
                long remainingTtl = bucket.remainTimeToLive() / 1000;
                if (remainingTtl > 0) {
                    bucket.set(session, Duration.ofSeconds(remainingTtl));
                }
                throw new BusinessException(ErrorCode.ERR_OTP_INVALID);
            }
        }

        // Xác thực thành công -> Hủy OTP khỏi Redis ngay lập tức
        bucket.delete();
        log.info("OTP verified successfully and consumed: purpose={}, identifier={}", purpose, identifier);
        return true;
    }

    @Override
    public boolean isOtpCoolingDown(String identifier, String purpose) {
        String cooldownKey = COOLDOWN_PREFIX + purpose + ":" + identifier;
        return redissonClient.getBucket(cooldownKey).isExists();
    }

    @Override
    public long getRemainingCooldown(String identifier, String purpose) {
        String cooldownKey = COOLDOWN_PREFIX + purpose + ":" + identifier;
        long ttlMillis = redissonClient.getBucket(cooldownKey).remainTimeToLive();
        return Math.max(0, ttlMillis / 1000);
    }

    @Override
    public String generateStepUpToken(String businessId, UserType userType, String purpose, String identifier) {
        String jti = UUID.randomUUID().toString();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + (STEP_UP_TOKEN_EXPIRATION_SECONDS * 1000));

        return Jwts.builder()
                .header().type("JWT").and()
                .subject(businessId)
                .id(jti)
                .issuer(jwtProperties.getIssuer())
                .issuedAt(now)
                .expiration(expiryDate)
                .claim("userType", userType.name())
                .claim("purpose", purpose)
                .claim("identifier", identifier)
                .signWith(secretKey, Jwts.SIG.HS256)
                .compact();
    }

    @Override
    public StepUpTokenClaims validateAndConsumeStepUpToken(String token, String expectedPurpose) {
        if (token == null || token.isBlank()) {
            throw new BusinessException(ErrorCode.ERR_ACTIVATION_TOKEN_INVALID);
        }

        try {
            Claims claims = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String jti = claims.getId();
            String purpose = claims.get("purpose", String.class);
            String userTypeStr = claims.get("userType", String.class);
            String identifier = claims.get("identifier", String.class);
            String businessId = claims.getSubject();

            if (tokenBlacklistPort.isBlacklisted(jti)) {
                log.warn("Step-up token is already consumed/blacklisted: jti={}", jti);
                throw new BusinessException(ErrorCode.ERR_ACTIVATION_TOKEN_INVALID);
            }

            if (!expectedPurpose.equalsIgnoreCase(purpose)) {
                log.warn("Step-up token purpose mismatch: expected={}, actual={}", expectedPurpose, purpose);
                throw new BusinessException(ErrorCode.ERR_ACTIVATION_TOKEN_INVALID);
            }

            // Thu hồi token ngay lập tức sau khi dùng (One-time token)
            Date expiration = claims.getExpiration();
            long remainingSeconds = Math.max(1, (expiration.getTime() - System.currentTimeMillis()) / 1000);
            tokenBlacklistPort.blacklistToken(jti, remainingSeconds);

            log.info("Step-up token validated and consumed: businessId={}, purpose={}, jti={}", businessId, purpose, jti);

            return StepUpTokenClaims.builder()
                    .jti(jti)
                    .businessId(businessId)
                    .userType(UserType.valueOf(userTypeStr))
                    .purpose(purpose)
                    .identifier(identifier)
                    .remainingTtlSeconds(remainingSeconds)
                    .build();

        } catch (ExpiredJwtException e) {
            log.warn("Step-up token expired: {}", e.getMessage());
            throw new BusinessException(ErrorCode.ERR_TOKEN_EXPIRED);
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid Step-up token: {}", e.getMessage());
            throw new BusinessException(ErrorCode.ERR_ACTIVATION_TOKEN_INVALID);
        }
    }
}
