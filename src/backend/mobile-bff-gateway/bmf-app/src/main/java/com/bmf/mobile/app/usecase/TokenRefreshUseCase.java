package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.RefreshTokenRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.RefreshTokenData;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * UseCase xử lý làm mới Access Token bằng Refresh Token (Token Rotation).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TokenRefreshUseCase {

    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;

    private static final String BEARER_TYPE = "Bearer";

    public AuthResponse refresh(RefreshTokenRequest request) {
        log.info("Processing token refresh: deviceId={}", request.getDeviceId());

        RefreshTokenData tokenData = tokenBlacklistPort.getRefreshTokenData(request.getRefreshToken());

        if (tokenData == null) {
            log.warn("Token refresh failed - invalid or expired refresh token: deviceId={}", request.getDeviceId());
            throw new BusinessException(ErrorCode.ERR_TOKEN_EXPIRED);
        }

        if (!tokenData.getDeviceId().equals(request.getDeviceId())) {
            log.warn("Token refresh failed - device mismatch: expected={}, received={}",
                    tokenData.getDeviceId(), request.getDeviceId());
            tokenBlacklistPort.revokeRefreshToken(request.getRefreshToken());
            throw new BusinessException(ErrorCode.ERR_TOKEN_INVALID);
        }

        UserType userType = UserType.valueOf(tokenData.getUserType());
        PlatformType platform = tokenData.getPlatform() != null ? PlatformType.valueOf(tokenData.getPlatform()) : null;

        // Thu hồi Refresh Token cũ (Token Rotation)
        tokenBlacklistPort.revokeRefreshToken(request.getRefreshToken());

        // Cấp mới cặp Token
        String newAccessToken = tokenProviderPort.generateAccessToken(
                tokenData.getUserId(), userType, tokenData.getDeviceId(), platform);
        String newRefreshToken = tokenProviderPort.generateRefreshToken();

        // Lưu Refresh Token mới vào Redis
        tokenBlacklistPort.storeRefreshToken(
                newRefreshToken, tokenData.getUserId(), userType, tokenData.getDeviceId(), platform);

        log.info("Token successfully refreshed: userId={}, userType={}", tokenData.getUserId(), userType);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType(BEARER_TYPE)
                .expiresIn(tokenProviderPort.getAccessTokenExpirationSeconds())
                .userType(userType)
                .userId(tokenData.getUserId())
                .deviceId(tokenData.getDeviceId())
                .platform(platform)
                .deviceActive(true)
                .build();
    }
}
