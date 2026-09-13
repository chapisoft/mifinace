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
import lombok.ToString;

/**
 * Request đăng nhập cho Agent (Trưởng nhóm / Trưởng cụm).
 * Agent là Khách hàng trong KH_THANHVIEN được giao vai trò Trưởng nhóm/cụm,
 * đăng nhập bằng Mã thành viên (hoặc NRC/SĐT) và mã PIN 6 số.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = {"pinCode", "password"})
public class AgentLoginRequest {

    /**
     * Mã thành viên (Ma_ThanhVien), Số thẻ NRC, hoặc Số điện thoại.
     */
    private String identifier;

    /**
     * Tương thích với trường username cũ.
     */
    private String username;

    /**
     * Mã PIN bảo mật 6 số.
     */
    private String pinCode;

    /**
     * Tương thích với trường password cũ.
     */
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

    public String getEffectiveIdentifier() {
        if (identifier != null && !identifier.isBlank()) {
            return identifier;
        }
        if (username != null && !username.isBlank()) {
            return username;
        }
        return "";
    }

    public String getEffectivePin() {
        if (pinCode != null && !pinCode.isBlank()) {
            return pinCode;
        }
        if (password != null && !password.isBlank()) {
            return password;
        }
        return "";
    }
}
