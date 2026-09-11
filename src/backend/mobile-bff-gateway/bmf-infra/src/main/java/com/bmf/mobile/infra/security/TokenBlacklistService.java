package com.bmf.mobile.infra.security;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.port.RefreshTokenData;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RBucket;
import org.redisson.api.RedissonClient;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * Quản lý Token Blacklist, Refresh Token Session và Bẫy Brute-force PIN trên bộ nhớ đệm phân tán Redis (Triển khai TokenBlacklistPort).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TokenBlacklistService implements TokenBlacklistPort {

    private final RedissonClient redissonClient;
    private final JwtProperties jwtProperties;

    private static final String BLACKLIST_PREFIX = "BMF:BLACKLIST_TOKEN:";
    private static final String REFRESH_TOKEN_PREFIX = "BMF:REFRESH_TOKEN:";
    private static final String PIN_FAIL_PREFIX = "BMF:PIN_FAIL:";
    private static final int MAX_PIN_FAIL_ATTEMPTS = 5;
    private static final long PIN_LOCKOUT_DURATION_SECONDS = 900; // 15 phút

    @Override
    public void blacklistToken(String jti, long remainingTtlSeconds) {
        if (jti == null || jti.isBlank() || remainingTtlSeconds <= 0) {
            return;
        }
        String key = BLACKLIST_PREFIX + jti;
        RBucket<String> bucket = redissonClient.getBucket(key);
        bucket.set("REVOKED", Duration.ofSeconds(remainingTtlSeconds));
        log.info("Token blacklisted: jti={}, ttlSeconds={}", jti, remainingTtlSeconds);
    }

    @Override
    public boolean isBlacklisted(String jti) {
        if (jti == null || jti.isBlank()) {
            return true;
        }
        String key = BLACKLIST_PREFIX + jti;
        return redissonClient.getBucket(key).isExists();
    }

    @Override
    public void storeRefreshToken(String refreshToken, String userId, UserType userType, String deviceId, PlatformType platform) {
        String key = REFRESH_TOKEN_PREFIX + refreshToken;
        RefreshTokenData data = RefreshTokenData.builder()
                .userId(userId)
                .userType(userType.name())
                .deviceId(deviceId)
                .platform(platform != null ? platform.name() : null)
                .build();

        RBucket<RefreshTokenData> bucket = redissonClient.getBucket(key);
        bucket.set(data, Duration.ofSeconds(jwtProperties.getRefreshTokenExpirationSeconds()));
        log.info("Refresh token stored in Redis: userId={}, userType={}, deviceId={}", userId, userType, deviceId);
    }

    @Override
    public RefreshTokenData getRefreshTokenData(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return null;
        }
        String key = REFRESH_TOKEN_PREFIX + refreshToken;
        RBucket<RefreshTokenData> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }

    @Override
    public void revokeRefreshToken(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return;
        }
        String key = REFRESH_TOKEN_PREFIX + refreshToken;
        redissonClient.getBucket(key).delete();
        log.info("Refresh token revoked: key={}", key);
    }

    @Override
    public long recordPinFailure(String nrc) {
        String key = PIN_FAIL_PREFIX + nrc;
        RBucket<Integer> bucket = redissonClient.getBucket(key);
        Integer current = bucket.get();
        int attempts = (current == null ? 0 : current) + 1;
        bucket.set(attempts, Duration.ofSeconds(PIN_LOCKOUT_DURATION_SECONDS));
        log.warn("Recorded failed PIN attempt: nrc={}, attempts={}/{}", nrc, attempts, MAX_PIN_FAIL_ATTEMPTS);
        return attempts;
    }

    @Override
    public boolean isPinLocked(String nrc) {
        String key = PIN_FAIL_PREFIX + nrc;
        RBucket<Integer> bucket = redissonClient.getBucket(key);
        Integer current = bucket.get();
        return current != null && current >= MAX_PIN_FAIL_ATTEMPTS;
    }

    @Override
    public void resetPinFailure(String nrc) {
        String key = PIN_FAIL_PREFIX + nrc;
        redissonClient.getBucket(key).delete();
        log.info("Reset PIN failure counter for NRC: {}", nrc);
    }
}
