package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.AgentLoginRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.entity.SysUser;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.PasswordEncoderPort;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import com.bmf.mobile.domain.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AgentAuthenticationUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private MobileDeviceRepository deviceRepository;

    @Mock
    private TokenProviderPort tokenProviderPort;

    @Mock
    private TokenBlacklistPort tokenBlacklistPort;

    @Mock
    private PasswordEncoderPort passwordEncoderPort;

    @InjectMocks
    private AgentAuthenticationUseCase agentAuthenticationUseCase;

    private AgentLoginRequest validRequest;
    private SysUser activeUser;

    @BeforeEach
    void setUp() {
        validRequest = AgentLoginRequest.builder()
                .username("BMF_OFFICER_01")
                .password("Password@2026")
                .deviceId("DEV-AGENT-001")
                .platform(PlatformType.ANDROID)
                .deviceName("Samsung Galaxy Tab A8")
                .osVersion("Android 14")
                .appVersion("1.0.0")
                .pushToken("FCM_TOKEN_SAMPLE")
                .publicKey("PUBLIC_KEY_SAMPLE")
                .build();

        activeUser = SysUser.builder()
                .userId("USR001")
                .username("BMF_OFFICER_01")
                .fullName("U Aung Kyaw")
                .passwordHash("$2a$10$hashedPasswordSample")
                .branchCode("BR001")
                .active(true)
                .createdTime(LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("Đăng nhập Cán bộ tín dụng thành công - Cấp Access Token và Refresh Token")
    void authenticateSuccessShouldReturnAuthResponse() {
        when(userRepository.findByUsername("BMF_OFFICER_01")).thenReturn(Optional.of(activeUser));
        when(passwordEncoderPort.matches("Password@2026", activeUser.getPasswordHash())).thenReturn(true);
        when(deviceRepository.findByDeviceIdAndUserId("DEV-AGENT-001", "USR001")).thenReturn(Optional.empty());
        when(tokenProviderPort.generateAccessToken("USR001", UserType.AGENT, "DEV-AGENT-001", PlatformType.ANDROID))
                .thenReturn("MOCK_ACCESS_TOKEN");
        when(tokenProviderPort.generateRefreshToken()).thenReturn("MOCK_REFRESH_TOKEN");
        when(tokenProviderPort.getAccessTokenExpirationSeconds()).thenReturn(900L);

        AuthResponse response = agentAuthenticationUseCase.authenticate(validRequest);

        assertNotNull(response);
        assertEquals("MOCK_ACCESS_TOKEN", response.getAccessToken());
        assertEquals("MOCK_REFRESH_TOKEN", response.getRefreshToken());
        assertEquals(UserType.AGENT, response.getUserType());
        assertEquals("USR001", response.getUserId());
        assertEquals("U Aung Kyaw", response.getFullName());
        assertEquals("BR001", response.getBranchCode());
        assertEquals(900L, response.getExpiresIn());

        verify(deviceRepository).save(any(MobileDevice.class));
        verify(tokenBlacklistPort).storeRefreshToken(
                "MOCK_REFRESH_TOKEN", "USR001", UserType.AGENT, "DEV-AGENT-001", PlatformType.ANDROID);
    }

    @Test
    @DisplayName("Đăng nhập Cán bộ thất bại - Tên đăng nhập không tồn tại")
    void authenticateUserNotFoundShouldThrowBusinessException() {
        when(userRepository.findByUsername("NON_EXISTENT")).thenReturn(Optional.empty());

        AgentLoginRequest request = AgentLoginRequest.builder()
                .username("NON_EXISTENT")
                .password("Password@2026")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_CREDENTIALS_INVALID, ex.getErrorCode());
    }

    @Test
    @DisplayName("Đăng nhập Cán bộ thất bại - Mật khẩu không chính xác")
    void authenticatePasswordMismatchShouldThrowBusinessException() {
        when(userRepository.findByUsername("BMF_OFFICER_01")).thenReturn(Optional.of(activeUser));
        when(passwordEncoderPort.matches("WrongPassword", activeUser.getPasswordHash())).thenReturn(false);

        AgentLoginRequest request = AgentLoginRequest.builder()
                .username("BMF_OFFICER_01")
                .password("WrongPassword")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_CREDENTIALS_INVALID, ex.getErrorCode());
    }

    @Test
    @DisplayName("Đăng nhập Cán bộ thất bại - Tài khoản đang bị vô hiệu hóa")
    void authenticateDisabledAccountShouldThrowBusinessException() {
        SysUser disabledUser = SysUser.builder()
                .userId("USR002")
                .username("BMF_OFFICER_DISABLED")
                .passwordHash("$2a$10$hashedPassword")
                .active(false)
                .build();

        when(userRepository.findByUsername("BMF_OFFICER_DISABLED")).thenReturn(Optional.of(disabledUser));

        AgentLoginRequest request = AgentLoginRequest.builder()
                .username("BMF_OFFICER_DISABLED")
                .password("Password@2026")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_FORBIDDEN, ex.getErrorCode());
    }

    @Test
    @DisplayName("Đăng nhập Cán bộ thất bại - Thiết bị đang bị khóa bảo mật")
    void authenticateLockedDeviceShouldThrowBusinessException() {
        MobileDevice lockedDevice = MobileDevice.builder()
                .deviceId("DEV-AGENT-LOCKED")
                .userId("USR001")
                .active(false)
                .build();

        when(userRepository.findByUsername("BMF_OFFICER_01")).thenReturn(Optional.of(activeUser));
        when(passwordEncoderPort.matches("Password@2026", activeUser.getPasswordHash())).thenReturn(true);
        when(deviceRepository.findByDeviceIdAndUserId("DEV-AGENT-LOCKED", "USR001"))
                .thenReturn(Optional.of(lockedDevice));

        AgentLoginRequest request = AgentLoginRequest.builder()
                .username("BMF_OFFICER_01")
                .password("Password@2026")
                .deviceId("DEV-AGENT-LOCKED")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_DEVICE_BLOCKED, ex.getErrorCode());
    }
}
