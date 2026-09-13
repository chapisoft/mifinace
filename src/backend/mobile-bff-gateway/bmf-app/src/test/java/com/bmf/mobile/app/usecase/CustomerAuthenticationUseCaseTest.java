package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CustomerLoginRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.PasswordEncoderPort;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
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
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CustomerAuthenticationUseCaseTest {

    @Mock
    private CustomerRepository customerRepository;

    @Mock
    private com.bmf.mobile.domain.repository.AppUserRepository appUserRepository;

    @Mock
    private MobileDeviceRepository deviceRepository;

    @Mock
    private TokenProviderPort tokenProviderPort;

    @Mock
    private TokenBlacklistPort tokenBlacklistPort;

    @Mock
    private PasswordEncoderPort passwordEncoderPort;

    @InjectMocks
    private CustomerAuthenticationUseCase customerAuthenticationUseCase;

    private CustomerLoginRequest validRequest;
    private CustomerMember activeCustomer;
    private com.bmf.mobile.domain.entity.AppUser activeAppUser;

    @BeforeEach
    void setUp() {
        validRequest = CustomerLoginRequest.builder()
                .nrcNumber("12/DAGAMA(N)123456")
                .pinCode("123456")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .deviceName("Xiaomi Redmi Note 12")
                .osVersion("Android 13")
                .appVersion("1.0.0")
                .pushToken("FCM_CUST_TOKEN")
                .publicKey("PUBLIC_KEY_CUST")
                .build();

        activeCustomer = CustomerMember.builder()
                .customerCode("CUST-99001")
                .nrcNumber("12/DAGAMA(N)123456")
                .fullName("Daw Khin Myint")
                .pinHash("$2a$10$hashedPinSample123456")
                .groupCode("GRP-YGN-01")
                .centerCode("CTR-01")
                .township("Dagon Myothit")
                .active(true)
                .createdTime(LocalDateTime.now())
                .build();

        activeAppUser = com.bmf.mobile.domain.entity.AppUser.builder()
                .userId("APP-CUST-99001")
                .userType(UserType.CUSTOMER)
                .businessId("CUST-99001")
                .identifierKey("12/DAGAMA(N)123456")
                .fullName("Daw Khin Myint")
                .pinHash("$2a$10$hashedPinSample123456")
                .activated(true)
                .status("ACTIVE")
                .build();
    }

    @Test
    @DisplayName("Đăng nhập Khách hàng thành công bằng Mã thành viên hoặc NRC - Reset bộ đếm sai PIN và cấp Token")
    void authenticateSuccessShouldResetPinFailuresAndReturnAuthResponse() {
        when(tokenBlacklistPort.isPinLocked("12/DAGAMA(N)123456")).thenReturn(false);
        when(customerRepository.findByCustomerCode("12/DAGAMA(N)123456")).thenReturn(Optional.empty());
        when(customerRepository.findByNrcNumber("12/DAGAMA(N)123456")).thenReturn(Optional.of(activeCustomer));
        when(appUserRepository.findByBusinessId("CUST-99001", UserType.CUSTOMER)).thenReturn(Optional.of(activeAppUser));
        when(passwordEncoderPort.matches("123456", activeAppUser.getPinHash())).thenReturn(true);
        when(deviceRepository.findByDeviceIdAndUserId("DEV-CUST-001", "CUST-99001")).thenReturn(Optional.empty());
        when(tokenProviderPort.generateAccessToken("CUST-99001", UserType.CUSTOMER, "DEV-CUST-001", PlatformType.ANDROID))
                .thenReturn("MOCK_CUSTOMER_ACCESS_TOKEN");
        when(tokenProviderPort.generateRefreshToken()).thenReturn("MOCK_CUSTOMER_REFRESH_TOKEN");
        when(tokenProviderPort.getAccessTokenExpirationSeconds()).thenReturn(900L);

        AuthResponse response = customerAuthenticationUseCase.authenticate(validRequest);

        assertNotNull(response);
        assertEquals("MOCK_CUSTOMER_ACCESS_TOKEN", response.getAccessToken());
        assertEquals("MOCK_CUSTOMER_REFRESH_TOKEN", response.getRefreshToken());
        assertEquals(UserType.CUSTOMER, response.getUserType());
        assertEquals("CUST-99001", response.getUserId());
        assertEquals("Daw Khin Myint", response.getFullName());
        assertEquals("GRP-YGN-01", response.getGroupCode());

        verify(tokenBlacklistPort).resetPinFailure("CUST-99001");
        verify(tokenBlacklistPort).resetPinFailure("12/DAGAMA(N)123456");
        verify(appUserRepository).recordLoginSuccess("APP-CUST-99001");
        verify(deviceRepository).save(any(MobileDevice.class));
        verify(tokenBlacklistPort).storeRefreshToken(
                "MOCK_CUSTOMER_REFRESH_TOKEN", "CUST-99001", UserType.CUSTOMER, "DEV-CUST-001", PlatformType.ANDROID);
    }

    @Test
    @DisplayName("Đăng nhập Khách hàng trực tiếp bằng Ma_ThanhVien (Username chính)")
    void authenticateDirectCustomerCodeShouldSucceed() {
        CustomerLoginRequest codeRequest = CustomerLoginRequest.builder()
                .identifier("CUST-99001")
                .pinCode("123456")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .build();

        when(tokenBlacklistPort.isPinLocked("CUST-99001")).thenReturn(false);
        when(customerRepository.findByCustomerCode("CUST-99001")).thenReturn(Optional.of(activeCustomer));
        when(appUserRepository.findByBusinessId("CUST-99001", UserType.CUSTOMER)).thenReturn(Optional.of(activeAppUser));
        when(passwordEncoderPort.matches("123456", activeAppUser.getPinHash())).thenReturn(true);
        when(deviceRepository.findByDeviceIdAndUserId("DEV-CUST-001", "CUST-99001")).thenReturn(Optional.empty());
        when(tokenProviderPort.generateAccessToken("CUST-99001", UserType.CUSTOMER, "DEV-CUST-001", PlatformType.ANDROID))
                .thenReturn("MOCK_CUSTOMER_ACCESS_TOKEN");
        when(tokenProviderPort.generateRefreshToken()).thenReturn("MOCK_CUSTOMER_REFRESH_TOKEN");
        when(tokenProviderPort.getAccessTokenExpirationSeconds()).thenReturn(900L);

        AuthResponse response = customerAuthenticationUseCase.authenticate(codeRequest);

        assertNotNull(response);
        assertEquals("CUST-99001", response.getUserId());
        verify(customerRepository).findByCustomerCode("CUST-99001");
        verify(customerRepository, never()).findByNrcNumber(any());
    }

    @Test
    @DisplayName("Đăng nhập Khách hàng thất bại - Tài khoản đang bị khóa do nhập sai PIN quá 5 lần")
    void authenticateLockedPinShouldThrowPinBlockedException() {
        when(tokenBlacklistPort.isPinLocked("12/DAGAMA(N)123456")).thenReturn(true);

        BusinessException ex = assertThrows(BusinessException.class,
                () -> customerAuthenticationUseCase.authenticate(validRequest));

        assertEquals(ErrorCode.ERR_PIN_BLOCKED, ex.getErrorCode());
        verify(customerRepository, never()).findByNrcNumber(any());
    }

    @Test
    @DisplayName("Đăng nhập Khách hàng thất bại - Nhập sai PIN lần thứ 3 (chưa đạt 5 lần)")
    void authenticateWrongPinShouldRecordFailureAndThrowCredentialsInvalid() {
        when(tokenBlacklistPort.isPinLocked("12/DAGAMA(N)123456")).thenReturn(false);
        when(customerRepository.findByCustomerCode("12/DAGAMA(N)123456")).thenReturn(Optional.empty());
        when(customerRepository.findByNrcNumber("12/DAGAMA(N)123456")).thenReturn(Optional.of(activeCustomer));
        when(appUserRepository.findByBusinessId("CUST-99001", UserType.CUSTOMER)).thenReturn(Optional.of(activeAppUser));
        when(passwordEncoderPort.matches("999999", activeAppUser.getPinHash())).thenReturn(false);
        when(tokenBlacklistPort.recordPinFailure("CUST-99001")).thenReturn(3L);

        CustomerLoginRequest request = CustomerLoginRequest.builder()
                .nrcNumber("12/DAGAMA(N)123456")
                .pinCode("999999")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> customerAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_CREDENTIALS_INVALID, ex.getErrorCode());
        verify(tokenBlacklistPort).recordPinFailure("CUST-99001");
        verify(appUserRepository).recordPinFailure("APP-CUST-99001", 3);
    }

    @Test
    @DisplayName("Đăng nhập Khách hàng thất bại - Nhập sai PIN chạm ngưỡng 5 lần -> Kích hoạt khóa tài khoản")
    void authenticateWrongPinFifthAttemptShouldThrowPinBlockedException() {
        when(tokenBlacklistPort.isPinLocked("12/DAGAMA(N)123456")).thenReturn(false);
        when(customerRepository.findByCustomerCode("12/DAGAMA(N)123456")).thenReturn(Optional.empty());
        when(customerRepository.findByNrcNumber("12/DAGAMA(N)123456")).thenReturn(Optional.of(activeCustomer));
        when(appUserRepository.findByBusinessId("CUST-99001", UserType.CUSTOMER)).thenReturn(Optional.of(activeAppUser));
        when(passwordEncoderPort.matches("999999", activeAppUser.getPinHash())).thenReturn(false);
        when(tokenBlacklistPort.recordPinFailure("CUST-99001")).thenReturn(5L);

        CustomerLoginRequest request = CustomerLoginRequest.builder()
                .nrcNumber("12/DAGAMA(N)123456")
                .pinCode("999999")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .build();

        BusinessException ex = assertThrows(BusinessException.class,
                () -> customerAuthenticationUseCase.authenticate(request));

        assertEquals(ErrorCode.ERR_PIN_BLOCKED, ex.getErrorCode());
    }
}
