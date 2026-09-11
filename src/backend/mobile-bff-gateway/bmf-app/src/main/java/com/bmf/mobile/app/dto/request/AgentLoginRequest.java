package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.PlatformType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Request đăng nhập cho Cán bộ tín dụng (Loan Officer / Agent).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentLoginRequest {

    @NotBlank(message = "{validation.auth.username.notBlank}")
    @Size(max = 64, message = "{validation.auth.username.size}")
    private String username;

    @NotBlank(message = "{validation.auth.password.notBlank}")
    @Size(max = 128, message = "{validation.auth.password.size}")
    private String password;

    @NotBlank(message = "{validation.device.deviceId.notBlank}")
    @Size(max = 64, message = "{validation.device.deviceId.size}")
    private String deviceId;

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
