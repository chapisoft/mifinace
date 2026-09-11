package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.DeviceRegisterRequest;
import com.bmf.mobile.app.dto.response.DeviceRegisterResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * UseCase xử lý logic đăng ký / cập nhật thiết bị di động.
 * Đảm bảo 100% Zero-Hardcode, tuân thủ đa ngôn ngữ và log tiếng Anh kỹ thuật.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceRegistrationUseCase {

    private final MobileDeviceRepository deviceRepository;
    private final I18nService i18nService;

    public DeviceRegisterResponse registerOrUpdate(DeviceRegisterRequest request) {
        log.info("Processing device registration: deviceId={}, userId={}, userType={}, platform={}",
                request.getDeviceId(), request.getUserId(), request.getUserType(), request.getPlatform());

        Optional<MobileDevice> existingOpt = deviceRepository.findByDeviceIdAndUserId(
                request.getDeviceId(), request.getUserId());

        MobileDevice device;
        boolean isNew = false;

        if (existingOpt.isPresent()) {
            device = existingOpt.get();
            if (!device.isActive()) {
                log.warn("Blocked device attempt to register: deviceId={}, userId={}",
                        request.getDeviceId(), request.getUserId());
                throw new BusinessException(ErrorCode.ERR_DEVICE_BLOCKED);
            }
            device.setDeviceName(request.getDeviceName());
            device.setOsVersion(request.getOsVersion());
            device.setPublicKey(request.getPublicKey());
            device.recordActivity(request.getPushToken(), request.getAppVersion());
        } else {
            isNew = true;
            device = MobileDevice.builder()
                    .deviceId(request.getDeviceId())
                    .userId(request.getUserId())
                    .userType(request.getUserType())
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
        log.info("Device successfully {}: deviceId={}, userId={}",
                isNew ? "registered" : "updated", device.getDeviceId(), device.getUserId());

        String messageKey = isNew ? "msg.device.registered" : "msg.device.updated";
        String message = i18nService.getMessage(messageKey);

        return DeviceRegisterResponse.builder()
                .deviceId(device.getDeviceId())
                .userId(device.getUserId())
                .userType(device.getUserType())
                .platform(device.getPlatform())
                .active(device.isActive())
                .message(message)
                .registeredTime(device.getCreatedTime())
                .build();
    }
}
