package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * DTO phản hồi kết quả đăng ký thiết bị.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceRegisterResponse {

    private String deviceId;
    private String userId;
    private UserType userType;
    private PlatformType platform;
    private boolean active;
    private String message;
    private LocalDateTime registeredTime;
}
