package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.PlatformType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * Request thiết lập mã PIN lần đầu và kích hoạt tài khoản ứng dụng.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "pinCode")
public class ActivateAccountRequest {

    @NotBlank(message = "{validation.auth.activationToken.notBlank}")
    private String activationToken;

    @NotBlank(message = "{validation.auth.pin.notBlank}")
    @Pattern(regexp = "^[0-9]{6}$", message = "{validation.auth.pin.format}")
    private String pinCode;

    private boolean enableBiometric;

    @NotBlank(message = "{validation.device.deviceId.notBlank}")
    @Size(max = 64, message = "{validation.device.deviceId.size}")
    private String deviceId;

    @NotNull(message = "{validation.device.platform.notNull}")
    private PlatformType platform;

    @NotBlank(message = "{validation.device.appVersion.notBlank}")
    @Size(max = 16, message = "{validation.device.appVersion.size}")
    private String appVersion;

    @Size(max = 128, message = "{validation.device.deviceName.size}")
    private String deviceName;

    @Size(max = 32, message = "{validation.device.osVersion.size}")
    private String osVersion;

    @Size(max = 256, message = "{validation.device.pushToken.size}")
    private String pushToken;

    @Size(max = 512, message = "{validation.device.publicKey.size}")
    private String publicKey;
}
