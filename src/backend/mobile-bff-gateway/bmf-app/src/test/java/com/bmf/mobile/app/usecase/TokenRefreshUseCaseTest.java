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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TokenRefreshUseCaseTest {

    @Mock
    private TokenProviderPort tokenProviderPort;

    @Mock
    private TokenBlacklistPort tokenBlacklistPort;

    @InjectMocks
    private TokenRefreshUseCase tokenRefreshUseCase;

    private RefreshTokenRequest validRequest;
    private RefreshTokenData validSession;

    @BeforeEach
    void setUp() {
        validRequest = RefreshTokenRequest.builder()
                .refreshToken("OLD_REFRESH_TOKEN_123")
                .deviceId("DEV-AGENT-001")
                .build();

        validSession = RefreshTokenData.builder()
                .userId("USR001")
                .userType(UserType.AGENT.name())
                .deviceId("DEV-AGENT-001")
                .platform(PlatformType.ANDROID.name())
                .build();
    }

    @Test
    @DisplayName("Làm mới Token thành công - Token Rotation thu hồi Refresh Token cũ và cấp cặp mới")
    void refreshSuccessShouldRotateTokensAndReturnNewAuthResponse() {
        when(tokenBlacklistPort.getRefreshTokenData("OLD_REFRESH_TOKEN_123")).thenReturn(validSession);
        when(tokenProviderPort.generateAccessToken("USR001", UserType.AGENT, "DEV-AGENT-001", PlatformType.ANDROID))
                .thenReturn("NEW_ACCESS_TOKEN_456");
        when(tokenProviderPort.generateRefreshToken()).thenReturn("NEW_REFRESH_TOKEN_789");
        when(tokenProviderPort.getAccessTokenExpirationSeconds()).thenReturn(900L);

        AuthResponse response = tokenRefreshUseCase.refresh(validRequest);

        assertNotNull(response);
        assertEquals("NEW_ACCESS_TOKEN_456", response.getAccessToken());
        assertEquals("NEW_REFRESH_TOKEN_789", response.getRefreshToken());
        assertEquals(UserType.AGENT, response.getUserType());
        assertEquals("USR001", response.getUserId());

        // Kiểm tra thu hồi Refresh Token cũ và lưu token mới
        verify(tokenBlacklistPort).revokeRefreshToken("OLD_REFRESH_TOKEN_123");
        verify(tokenBlacklistPort).storeRefreshToken(
                "NEW_REFRESH_TOKEN_789", "USR001", UserType.AGENT, "DEV-AGENT-001", PlatformType.ANDROID);
    }

    @Test
    @DisplayName("Làm mới Token thất bại - Refresh Token không tồn tại hoặc đã hết hạn trong Redis")
    void refreshExpiredTokenShouldThrowTokenExpiredException() {
        when(tokenBlacklistPort.getRefreshTokenData("INVALID_OR_EXPIRED_TOKEN")).thenReturn(null);

        RefreshTokenRequest request = RefreshTokenRequest.builder()
                .refreshToken("INVALID_OR_EXPIRED_TOKEN")
                .deviceId("DEV-AGENT-001")
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> tokenRefreshUseCase.refresh(request));

        assertEquals(ErrorCode.ERR_TOKEN_EXPIRED, ex.getErrorCode());
    }

    @Test
    @DisplayName("Làm mới Token thất bại - Device ID không khớp (nguy cơ đánh cắp token)")
    void refreshDeviceMismatchShouldRevokeTokenAndThrowTokenInvalidException() {
        when(tokenBlacklistPort.getRefreshTokenData("OLD_REFRESH_TOKEN_123")).thenReturn(validSession);

        RefreshTokenRequest request = RefreshTokenRequest.builder()
                .refreshToken("OLD_REFRESH_TOKEN_123")
                .deviceId("DEV-ATTACKER-UNKNOWN")
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> tokenRefreshUseCase.refresh(request));

        assertEquals(ErrorCode.ERR_TOKEN_INVALID, ex.getErrorCode());
        // Thu hồi ngay lập tức để phòng vệ
        verify(tokenBlacklistPort).revokeRefreshToken("OLD_REFRESH_TOKEN_123");
    }
}
