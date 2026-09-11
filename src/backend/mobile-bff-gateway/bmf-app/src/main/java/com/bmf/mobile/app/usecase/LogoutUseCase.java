package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.LogoutRequest;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * UseCase xử lý quy trình đăng xuất và vô hiệu hóa Token 2 chiều (Action-Gate Defense).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LogoutUseCase {

    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;

    public void logout(LogoutRequest request, String bearerToken) {
        log.info("Processing user logout request");

        // 1. Đưa Access Token hiện tại vào Redis Blacklist
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            String token = bearerToken.substring(7).trim();
            try {
                if (tokenProviderPort.validateToken(token)) {
                    String jti = tokenProviderPort.extractJti(token);
                    long remainingTtl = tokenProviderPort.getRemainingTtlSeconds(token);
                    tokenBlacklistPort.blacklistToken(jti, remainingTtl);
                    log.info("Access token blacklisted on logout: jti={}", jti);
                }
            } catch (Exception e) {
                log.warn("Failed to extract claims from access token on logout: {}", e.getMessage());
            }
        }

        // 2. Thu hồi Refresh Token trên Redis
        if (request != null && request.getRefreshToken() != null && !request.getRefreshToken().isBlank()) {
            tokenBlacklistPort.revokeRefreshToken(request.getRefreshToken());
            log.info("Refresh token revoked on logout");
        }

        log.info("User logout completed successfully");
    }
}
