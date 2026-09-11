package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Request đăng ký / đồng bộ thông tin thiết bị di động.
 * Áp dụng 100% i18n template keys cho Bean Validation.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceRegisterRequest {

    @NotBlank(message = "{validation.device.deviceId.notBlank}")
    @Size(max = 64, message = "{validation.device.deviceId.size}")
    private String deviceId;

    @NotBlank(message = "{validation.device.userId.notBlank}")
    @Size(max = 32, message = "{validation.device.userId.size}")
    private String userId;

    @NotNull(message = "{validation.device.userType.notNull}")
    private UserType userType;

    @NotNull(message = "{validation.device.platform.notNull}")
    private PlatformType platform;

    @Size(max = 128, message = "{validation.device.deviceName.size}")
    private String deviceName;

    @Size(max = 32, message = "{validation.device.osVersion.size}")
    private String osVersion;

    @NotBlank(message = "{validation.device.appVersion.notBlank}")
    @Size(max = 16, message = "{validation.device.appVersion.size}")
    private String appVersion;

    @Size(max = 256, message = "{validation.device.pushToken.size}")
    private String pushToken;

    @Size(max = 512, message = "{validation.device.publicKey.size}")
    private String publicKey;
}
