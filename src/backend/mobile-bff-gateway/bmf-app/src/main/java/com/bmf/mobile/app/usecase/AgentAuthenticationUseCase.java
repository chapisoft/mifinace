package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.AgentLoginRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.entity.SysUser;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.PasswordEncoderPort;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import com.bmf.mobile.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * UseCase xử lý quy trình xác thực đăng nhập của Cán bộ tín dụng (Loan Officer / Agent).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AgentAuthenticationUseCase {

    private final UserRepository userRepository;
    private final MobileDeviceRepository deviceRepository;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;
    private final PasswordEncoderPort passwordEncoderPort;

    private static final String BEARER_TYPE = "Bearer";

    public AuthResponse authenticate(AgentLoginRequest request) {
        log.info("Processing Agent authentication: username={}, deviceId={}, platform={}",
                request.getUsername(), request.getDeviceId(), request.getPlatform());

        SysUser user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> {
                    log.warn("Agent login failed - username not found: {}", request.getUsername());
                    return new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID);
                });

        if (!user.isActive()) {
            log.warn("Agent login failed - account is disabled: username={}", request.getUsername());
            throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
        }

        if (!passwordEncoderPort.matches(request.getPassword(), user.getPasswordHash())) {
            log.warn("Agent login failed - password mismatch: username={}", request.getUsername());
            throw new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID);
        }

        // Kiểm tra và cập nhật ràng buộc thiết bị
        Optional<MobileDevice> existingDeviceOpt = deviceRepository.findByDeviceIdAndUserId(
                request.getDeviceId(), user.getUserId());

        MobileDevice device;
        if (existingDeviceOpt.isPresent()) {
            device = existingDeviceOpt.get();
            if (!device.isActive()) {
                log.warn("Agent login blocked - device is locked: deviceId={}, userId={}",
                        request.getDeviceId(), user.getUserId());
                throw new BusinessException(ErrorCode.ERR_DEVICE_BLOCKED);
            }
            device.setDeviceName(request.getDeviceName());
            device.setOsVersion(request.getOsVersion());
            device.setPublicKey(request.getPublicKey());
            device.recordActivity(request.getPushToken(), request.getAppVersion());
        } else {
            device = MobileDevice.builder()
                    .deviceId(request.getDeviceId())
                    .userId(user.getUserId())
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

        // Sinh cặp Token JWT
        String accessToken = tokenProviderPort.generateAccessToken(
                user.getUserId(), UserType.AGENT, request.getDeviceId(), request.getPlatform());
        String refreshToken = tokenProviderPort.generateRefreshToken();

        // Lưu Refresh Token vào Redis
        tokenBlacklistPort.storeRefreshToken(
                refreshToken, user.getUserId(), UserType.AGENT, request.getDeviceId(), request.getPlatform());

        log.info("Agent login successful: userId={}, username={}, branchCode={}",
                user.getUserId(), user.getUsername(), user.getBranchCode());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(BEARER_TYPE)
                .expiresIn(tokenProviderPort.getAccessTokenExpirationSeconds())
                .userType(UserType.AGENT)
                .userId(user.getUserId())
                .fullName(user.getFullName())
                .branchCode(user.getBranchCode())
                .deviceId(device.getDeviceId())
                .platform(device.getPlatform())
                .deviceActive(device.isActive())
                .build();
    }
}
