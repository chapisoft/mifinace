package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CustomerLoginRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
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
    private final MobileDeviceRepository deviceRepository;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;
    private final PasswordEncoderPort passwordEncoderPort;

    private static final String BEARER_TYPE = "Bearer";

    public AuthResponse authenticate(CustomerLoginRequest request) {
        log.info("Processing Customer authentication: nrc={}, deviceId={}, platform={}",
                request.getNrcNumber(), request.getDeviceId(), request.getPlatform());

        // Kiểm tra bẫy Brute-force PIN
        if (tokenBlacklistPort.isPinLocked(request.getNrcNumber())) {
            log.warn("Customer login blocked by brute-force defense: nrc={}", request.getNrcNumber());
            throw new BusinessException(ErrorCode.ERR_PIN_BLOCKED);
        }

        CustomerMember customer = customerRepository.findByNrcNumber(request.getNrcNumber())
                .orElseThrow(() -> {
                    log.warn("Customer login failed - NRC not found: {}", request.getNrcNumber());
                    return new BusinessException(ErrorCode.ERR_USER_NOT_FOUND);
                });

        if (!customer.isActive()) {
            log.warn("Customer login failed - account is disabled: nrc={}, customerCode={}",
                    request.getNrcNumber(), customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
        }

        // So khớp mã PIN băm
        if (!passwordEncoderPort.matches(request.getPinCode(), customer.getPinHash())) {
            long failAttempts = tokenBlacklistPort.recordPinFailure(request.getNrcNumber());
            log.warn("Customer login failed - PIN mismatch: nrc={}, attempt={}", request.getNrcNumber(), failAttempts);

            if (failAttempts >= 5) {
                throw new BusinessException(ErrorCode.ERR_PIN_BLOCKED);
            }
            throw new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID);
        }

        // Đăng nhập đúng -> Xóa bộ đếm sai PIN
        tokenBlacklistPort.resetPinFailure(request.getNrcNumber());

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
