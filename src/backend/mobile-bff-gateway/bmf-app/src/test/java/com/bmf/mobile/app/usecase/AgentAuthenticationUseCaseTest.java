package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.AgentLoginRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.domain.entity.AppUser;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.PasswordEncoderPort;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import com.bmf.mobile.domain.repository.AppUserRepository;
import com.bmf.mobile.domain.repository.CustomerRepository;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
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
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AgentAuthenticationUseCaseTest {

    @Mock
    private CustomerRepository customerRepository;

    @Mock
    private AppUserRepository appUserRepository;

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
    private CustomerMember activeCustomer;
    private AppUser activeAppUser;

    @BeforeEach
    void setUp() {
        validRequest = AgentLoginRequest.builder()
                .identifier("CUST-001")
                .pinCode("123456")
                .deviceId("DEV-AGENT-001")
                .platform(PlatformType.ANDROID)
                .deviceName("Samsung Galaxy Tab A8")
                .osVersion("Android 14")
                .appVersion("1.0.0")
                .pushToken("FCM_TOKEN_SAMPLE")
                .publicKey("PUBLIC_KEY_SAMPLE")
                .build();

        activeCustomer = CustomerMember.builder()
                .customerCode("CUST-001")
                .fullName("Daw Khin Myint")
                .nrcNumber("12/DAGAMA(N)045612")
                .phoneNumber("09123456789")
                .groupCode("GRP-YGN-01")
                .centerCode("CTR-YGN-01")
                .township("Dagon Township")
                .active(true)
                .createdTime(LocalDateTime.now())
                .build();

        activeAppUser = AppUser.builder()
                .userId("APP-AGT-CUST-001")
                .userType(UserType.AGENT)
                .businessId("CUST-001")
                .identifierKey("CUST-001")
                .fullName("Daw Khin Myint")
                .pinHash("$2a$10$hashedPinSample")
                .activated(true)
                .status("ACTIVE")
                .build();
    }

    @Test
    @DisplayName("Đăng nhập Agent (Trưởng nhóm) thành công - Cấp Access Token và Refresh Token")
    void authenticateSuccessShouldReturnAuthResponse() {
        when(customerRepository.findByCustomerCode("CUST-001")).thenReturn(Optional.of(activeCustomer));
        when(customerRepository.isGroupOrCenterLeader("CUST-001", "Daw Khin Myint", "GRP-YGN-01", "CTR-YGN-01"))
                .thenReturn(true);
        when(appUserRepository.findByBusinessId("CUST-001", UserType.AGENT)).thenReturn(Optional.of(activeAppUser));
        when(tokenBlacklistPort.isPinLocked("CUST-001")).thenReturn(false);
        when(tokenBlacklistPort.isPinLocked("12/DAGAMA(N)045612")).thenReturn(false);
        when(passwordEncoderPort.matches("123456", activeAppUser.getPinHash())).thenReturn(true);
        when(deviceRepository.findByDeviceIdAndUserId("DEV-AGENT-001", "CUST-001")).thenReturn(Optional.empty());
        when(tokenProviderPort.generateAccessToken("CUST-001", UserType.AGENT, "DEV-AGENT-001", PlatformType.ANDROID))
                .thenReturn("MOCK_ACCESS_TOKEN");
        when(tokenProviderPort.generateRefreshToken()).thenReturn("MOCK_REFRESH_TOKEN");
        when(tokenProviderPort.getAccessTokenExpirationSeconds()).thenReturn(900L);

        AuthResponse response = agentAuthenticationUseCase.authenticate(validRequest);

        assertNotNull(response);
        assertEquals("MOCK_ACCESS_TOKEN", response.getAccessToken());
        assertEquals("MOCK_REFRESH_TOKEN", response.getRefreshToken());
        assertEquals(UserType.AGENT, response.getUserType());
        assertEquals("CUST-001", response.getUserId());
        assertEquals("Daw Khin Myint", response.getFullName());
        assertEquals("GRP-YGN-01", response.getGroupCode());
        assertEquals(900L, response.getExpiresIn());

        verify(deviceRepository).save(any(MobileDevice.class));
        verify(tokenBlacklistPort).storeRefreshToken(
                "MOCK_REFRESH_TOKEN", "CUST-001", UserType.AGENT, "DEV-AGENT-001", PlatformType.ANDROID);
    }

    @Test
    @DisplayName("Đăng nhập Agent thất bại - Mã thành viên không tồn tại trong Core Banking")
    void authenticateUserNotFoundShouldThrowBusinessException() {
        when(customerRepository.findByCustomerCode("NON_EXISTENT")).thenReturn(Optional.empty());

        AgentLoginRequest request = AgentLoginRequest.builder()
                .identifier("NON_EXISTENT")
                .pinCode("123456")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_USER_NOT_FOUND, ex.getErrorCode());
    }

    @Test
    @DisplayName("Đăng nhập Agent thất bại - Khách hàng không phải là Trưởng nhóm/cụm")
    void authenticateNotLeaderShouldThrowForbiddenException() {
        when(customerRepository.findByCustomerCode("CUST-001")).thenReturn(Optional.of(activeCustomer));
        when(customerRepository.isGroupOrCenterLeader("CUST-001", "Daw Khin Myint", "GRP-YGN-01", "CTR-YGN-01"))
                .thenReturn(false);

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(validRequest));

        assertEquals(ErrorCode.ERR_FORBIDDEN, ex.getErrorCode());
    }

    @Test
    @DisplayName("Đăng nhập Agent thất bại - Mã PIN không chính xác")
    void authenticatePasswordMismatchShouldThrowBusinessException() {
        when(customerRepository.findByCustomerCode("CUST-001")).thenReturn(Optional.of(activeCustomer));
        when(customerRepository.isGroupOrCenterLeader("CUST-001", "Daw Khin Myint", "GRP-YGN-01", "CTR-YGN-01"))
                .thenReturn(true);
        when(appUserRepository.findByBusinessId("CUST-001", UserType.AGENT)).thenReturn(Optional.of(activeAppUser));
        when(passwordEncoderPort.matches("999999", activeAppUser.getPinHash())).thenReturn(false);
        when(tokenBlacklistPort.recordPinFailure("CUST-001")).thenReturn(1L);

        AgentLoginRequest request = AgentLoginRequest.builder()
                .identifier("CUST-001")
                .pinCode("999999")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_CREDENTIALS_INVALID, ex.getErrorCode());
    }

    @Test
    @DisplayName("Đăng nhập Agent thất bại - Tài khoản chưa kích hoạt")
    void authenticateUnactivatedAccountShouldThrowBusinessException() {
        AppUser unactivatedUser = AppUser.builder()
                .userId("APP-AGT-CUST-001")
                .userType(UserType.AGENT)
                .businessId("CUST-001")
                .activated(false)
                .build();

        when(customerRepository.findByCustomerCode("CUST-001")).thenReturn(Optional.of(activeCustomer));
        when(customerRepository.isGroupOrCenterLeader("CUST-001", "Daw Khin Myint", "GRP-YGN-01", "CTR-YGN-01"))
                .thenReturn(true);
        when(appUserRepository.findByBusinessId("CUST-001", UserType.AGENT)).thenReturn(Optional.of(unactivatedUser));

        BusinessException ex = assertThrows(BusinessException.class,
                () -> agentAuthenticationUseCase.authenticate(validRequest));

        assertEquals(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED, ex.getErrorCode());
    }
}
