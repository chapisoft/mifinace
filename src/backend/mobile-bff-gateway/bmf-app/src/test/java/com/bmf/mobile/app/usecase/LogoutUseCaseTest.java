package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.LogoutRequest;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LogoutUseCaseTest {

    @Mock
    private TokenProviderPort tokenProviderPort;

    @Mock
    private TokenBlacklistPort tokenBlacklistPort;

    @InjectMocks
    private LogoutUseCase logoutUseCase;

    @Test
    @DisplayName("Đăng xuất thành công - Đưa Access Token JTI vào Blacklist và thu hồi Refresh Token")
    void logoutSuccessShouldBlacklistAccessTokenAndRevokeRefreshToken() {
        String bearerToken = "Bearer VALID_ACCESS_TOKEN_SAMPLE";
        String token = "VALID_ACCESS_TOKEN_SAMPLE";

        when(tokenProviderPort.validateToken(token)).thenReturn(true);
        when(tokenProviderPort.extractJti(token)).thenReturn("JTI_UUID_12345");
        when(tokenProviderPort.getRemainingTtlSeconds(token)).thenReturn(600L);

        LogoutRequest request = LogoutRequest.builder()
                .refreshToken("REFRESH_TOKEN_TO_REVOKE")
                .build();

        logoutUseCase.logout(request, bearerToken);

        verify(tokenBlacklistPort).blacklistToken("JTI_UUID_12345", 600L);
        verify(tokenBlacklistPort).revokeRefreshToken("REFRESH_TOKEN_TO_REVOKE");
    }
}
