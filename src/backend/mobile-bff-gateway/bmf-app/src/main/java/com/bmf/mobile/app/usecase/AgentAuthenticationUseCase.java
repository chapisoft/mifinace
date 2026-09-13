package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.AgentLoginRequest;
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
import com.bmf.mobile.domain.repository.AppUserRepository;
import com.bmf.mobile.domain.repository.CustomerRepository;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * UseCase xử lý quy trình xác thực đăng nhập của Agent (Trưởng nhóm / Trưởng cụm):
 * Agent bản chất là Khách hàng trong bảng KH_THANHVIEN được giao vai trò Trưởng nhóm/cụm.
 * Đăng nhập bằng Ma_ThanhVien (hoặc NRC/SĐT) và mã PIN 6 số bảo mật.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AgentAuthenticationUseCase {

    private final CustomerRepository customerRepository;
    private final AppUserRepository appUserRepository;
    private final MobileDeviceRepository deviceRepository;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;
    private final PasswordEncoderPort passwordEncoderPort;

    private static final String BEARER_TYPE = "Bearer";

    public AuthResponse authenticate(AgentLoginRequest request) {
        String identifier = request.getEffectiveIdentifier().trim();
        String pinCode = request.getEffectivePin().trim();

        log.info("Processing Agent authentication: identifier={}, deviceId={}, platform={}",
                identifier, request.getDeviceId(), request.getPlatform());

        // 1. Tìm hồ sơ khách hàng trong Core Banking (KH_THANHVIEN)
        CustomerMember customer = customerRepository.findByCustomerCode(identifier)
                .or(() -> customerRepository.findByNrcNumber(identifier))
                .or(() -> customerRepository.findByPhoneNumber(identifier))
                .orElseThrow(() -> {
                    log.warn("Agent login failed - member profile not found: identifier={}", identifier);
                    return new BusinessException(ErrorCode.ERR_USER_NOT_FOUND);
                });

        if (!customer.isActive()) {
            log.warn("Agent login failed - customer account is disabled: customerCode={}", customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
        }

        // 2. Kiểm tra quyền hạn Trưởng nhóm / Trưởng cụm
        boolean isLeader = customerRepository.isGroupOrCenterLeader(
                customer.getCustomerCode(), customer.getFullName(), customer.getGroupCode(), customer.getCenterCode());

        if (!isLeader) {
            log.warn("Agent login rejected - customer is not a Group Leader / Center Chief: customerCode={}",
                    customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
        }

        // 3. Kiểm tra trạng thái tài khoản trong SYS_APP_USER với vai trò AGENT
        AppUser appUser = appUserRepository.findByBusinessId(customer.getCustomerCode(), UserType.AGENT)
                .orElseThrow(() -> {
                    log.warn("Agent account not activated in App: customerCode={}", customer.getCustomerCode());
                    return new BusinessException(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED);
                });

        if (!appUser.isActivated() || appUser.getPinHash() == null) {
            log.warn("Agent account is not yet activated: customerCode={}", customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED);
        }

        // 4. Kiểm tra khóa PIN
        if (tokenBlacklistPort.isPinLocked(customer.getCustomerCode())
                || tokenBlacklistPort.isPinLocked(customer.getNrcNumber())) {
            log.warn("Agent PIN is locked due to consecutive failures: customerCode={}", customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_PIN_BLOCKED);
        }

        // 5. So khớp mã PIN băm BCrypt
        if (!passwordEncoderPort.matches(pinCode, appUser.getPinHash())) {
            long failAttempts = tokenBlacklistPort.recordPinFailure(customer.getCustomerCode());
            appUserRepository.recordPinFailure(appUser.getUserId(), (int) failAttempts);
            log.warn("Agent PIN mismatch: customerCode={}, failCount={}", customer.getCustomerCode(), failAttempts);
            if (failAttempts >= 5) {
                throw new BusinessException(ErrorCode.ERR_PIN_BLOCKED);
            }
            throw new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID);
        }

        // Đăng nhập thành công -> Reset số lần sai PIN
        tokenBlacklistPort.resetPinFailure(customer.getCustomerCode());
        appUserRepository.recordLoginSuccess(appUser.getUserId());

        // 6. Cập nhật thiết bị
        Optional<MobileDevice> existingDeviceOpt = deviceRepository.findByDeviceIdAndUserId(
                request.getDeviceId(), customer.getCustomerCode());

        MobileDevice device;
        if (existingDeviceOpt.isPresent()) {
            device = existingDeviceOpt.get();
            if (!device.isActive()) {
                log.warn("Agent login blocked - device is locked: deviceId={}, customerCode={}",
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
                    .userType(UserType.AGENT)
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

        // 7. Sinh cặp Token JWT Agent
        String accessToken = tokenProviderPort.generateAccessToken(
                customer.getCustomerCode(), UserType.AGENT, request.getDeviceId(), request.getPlatform());
        String refreshToken = tokenProviderPort.generateRefreshToken();

        tokenBlacklistPort.storeRefreshToken(
                refreshToken, customer.getCustomerCode(), UserType.AGENT, request.getDeviceId(), request.getPlatform());

        log.info("Agent login successful: customerCode={}, fullName={}, groupCode={}",
                customer.getCustomerCode(), customer.getFullName(), customer.getGroupCode());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(BEARER_TYPE)
                .expiresIn(tokenProviderPort.getAccessTokenExpirationSeconds())
                .userType(UserType.AGENT)
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
