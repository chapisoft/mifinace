package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CustomerLoginRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.domain.entity.AppUser;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.PasswordEncoderPort;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import com.bmf.mobile.domain.repository.CustomerRepository;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * UseCase xử lý quy trình xác thực đăng nhập của Khách hàng thành viên qua số thẻ NRC và mã PIN 6 số.
 * Tích hợp bẫy phòng chống Brute-force PIN trên Redis (khóa 15 phút nếu nhập sai quá 5 lần).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerAuthenticationUseCase {

    private final CustomerRepository customerRepository;
    private final com.bmf.mobile.domain.repository.AppUserRepository appUserRepository;
    private final MobileDeviceRepository deviceRepository;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;
    private final PasswordEncoderPort passwordEncoderPort;

    private static final String BEARER_TYPE = "Bearer";

    public AuthResponse authenticate(CustomerLoginRequest request) {
        String identifier = request.getEffectiveIdentifier().trim();
        log.info("Processing Customer authentication: identifier={}, deviceId={}, platform={}",
                identifier, request.getDeviceId(), request.getPlatform());

        // Kiểm tra bẫy Brute-force PIN
        if (tokenBlacklistPort.isPinLocked(identifier)) {
            log.warn("Customer login blocked by brute-force defense: identifier={}", identifier);
            throw new BusinessException(ErrorCode.ERR_PIN_BLOCKED);
        }

        // Tìm kiếm hồ sơ thành viên: Ưu tiên Ma_ThanhVien, sau đó tới So_NRC và So_DienThoai
        CustomerMember customer = customerRepository.findByCustomerCode(identifier)
                .or(() -> customerRepository.findByNrcNumber(identifier))
                .or(() -> customerRepository.findByPhoneNumber(identifier))
                .orElseThrow(() -> {
                    log.warn("Customer login failed - Account not found in Core: {}", identifier);
                    return new BusinessException(ErrorCode.ERR_USER_NOT_FOUND);
                });

        if (!customer.isActive()) {
            log.warn("Customer login failed - account is disabled: identifier={}, customerCode={}",
                    identifier, customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
        }

        // Bắt buộc tài khoản đã kích hoạt trên App (khóa ngoại Business_Id = Ma_ThanhVien)
        AppUser appUser = appUserRepository.findByBusinessId(customer.getCustomerCode(), UserType.CUSTOMER)
                .or(() -> appUserRepository.findByIdentifier(customer.getCustomerCode(), UserType.CUSTOMER))
                .orElseThrow(() -> {
                    log.warn("Customer login failed - App account not activated: customerCode={}", customer.getCustomerCode());
                    return new BusinessException(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED);
                });

        if (!appUser.isActivated() || appUser.getPinHash() == null) {
            log.warn("Customer login failed - App account is not active: customerCode={}", customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED);
        }

        // So khớp mã PIN băm
        String targetPinHash = appUser.getPinHash() != null ? appUser.getPinHash() : customer.getPinHash();
        if (!passwordEncoderPort.matches(request.getPinCode(), targetPinHash)) {
            long failAttempts = tokenBlacklistPort.recordPinFailure(customer.getCustomerCode());
            appUserRepository.recordPinFailure(appUser.getUserId(), (int) failAttempts);
            log.warn("Customer login failed - PIN mismatch: customerCode={}, attempt={}", customer.getCustomerCode(), failAttempts);

            if (failAttempts >= 5) {
                throw new BusinessException(ErrorCode.ERR_PIN_BLOCKED);
            }
            throw new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID);
        }

        // Đăng nhập đúng -> Xóa bộ đếm sai PIN
        tokenBlacklistPort.resetPinFailure(customer.getCustomerCode());
        if (customer.getNrcNumber() != null && !customer.getNrcNumber().equalsIgnoreCase(customer.getCustomerCode())) {
            tokenBlacklistPort.resetPinFailure(customer.getNrcNumber());
        }
        if (!identifier.equalsIgnoreCase(customer.getCustomerCode())
                && (customer.getNrcNumber() == null || !identifier.equalsIgnoreCase(customer.getNrcNumber()))) {
            tokenBlacklistPort.resetPinFailure(identifier);
        }
        appUserRepository.recordLoginSuccess(appUser.getUserId());

        // Kiểm tra và cập nhật thiết bị
        Optional<MobileDevice> existingDeviceOpt = deviceRepository.findByDeviceIdAndUserId(
                request.getDeviceId(), customer.getCustomerCode());

        MobileDevice device;
        if (existingDeviceOpt.isPresent()) {
            device = existingDeviceOpt.get();
            if (!device.isActive()) {
                log.warn("Customer login blocked - device is locked: deviceId={}, customerCode={}",
                        request.getDeviceId(), customer.getCustomerCode());
                throw new BusinessException(ErrorCode.ERR_DEVICE_BLOCKED);
            }
            device.setDeviceName(request.getDeviceName());
            device.setOsVersion(request.getOsVersion());
            device.setPublicKey(request.getPublicKey());
            device.recordActivity(request.getPushToken(), request.getAppVersion());
        } else {
            device = MobileDevice.builder()
                    .deviceId(request.getDeviceId())
                    .userId(customer.getCustomerCode())
                    .userType(UserType.CUSTOMER)
                    .platform(request.getPlatform())
                    .deviceName(request.getDeviceName())
                    .osVersion(request.getOsVersion())
                    .appVersion(request.getAppVersion())
                    .pushToken(request.getPushToken())
                    .publicKey(request.getPublicKey())
                    .active(true)
                    .lastActiveTime(LocalDateTime.now())
                    .createdTime(LocalDateTime.now())
                    .updatedTime(LocalDateTime.now())
                    .build();
        }
        deviceRepository.save(device);

        // Sinh cặp Token JWT
        String accessToken = tokenProviderPort.generateAccessToken(
                customer.getCustomerCode(), UserType.CUSTOMER, request.getDeviceId(), request.getPlatform());
        String refreshToken = tokenProviderPort.generateRefreshToken();

        // Lưu Refresh Token vào Redis
        tokenBlacklistPort.storeRefreshToken(
                refreshToken, customer.getCustomerCode(), UserType.CUSTOMER, request.getDeviceId(), request.getPlatform());

        log.info("Customer login successful: customerCode={}, nrc={}, groupCode={}",
                customer.getCustomerCode(), customer.getNrcNumber(), customer.getGroupCode());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(BEARER_TYPE)
                .expiresIn(tokenProviderPort.getAccessTokenExpirationSeconds())
                .userType(UserType.CUSTOMER)
                .userId(customer.getCustomerCode())
                .fullName(customer.getFullName())
                .groupCode(customer.getGroupCode())
                .centerCode(customer.getCenterCode())
                .township(customer.getTownship())
                .deviceId(device.getDeviceId())
                .platform(device.getPlatform())
                .deviceActive(device.isActive())
                .build();
    }
}
