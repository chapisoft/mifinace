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
 * Request thiết lập lại mã PIN mới sau khi xác thực OTP quên PIN.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "newPinCode")
public class ResetPinRequest {

    @NotBlank(message = "{validation.auth.resetToken.notBlank}")
    private String resetPinToken;

    @NotBlank(message = "{validation.auth.pin.notBlank}")
    @Pattern(regexp = "^[0-9]{6}$", message = "{validation.auth.pin.format}")
    private String newPinCode;

    @NotBlank(message = "{validation.device.deviceId.notBlank}")
    @Size(max = 64, message = "{validation.device.deviceId.size}")
    private String deviceId;

    @NotNull(message = "{validation.device.platform.notNull}")
    private PlatformType platform;

    @NotBlank(message = "{validation.device.appVersion.notBlank}")
    @Size(max = 16, message = "{validation.device.appVersion.size}")
    private String appVersion;
}
