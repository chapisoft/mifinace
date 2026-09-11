package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho một thiết bị di động đã đăng ký trong hệ thống.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class MobileDevice {

    private String deviceId;
    private String userId;
    private UserType userType;
    private PlatformType platform;
    private String deviceName;
    private String osVersion;
    private String appVersion;
    private String pushToken;
    private String publicKey;
    private boolean active;
    private LocalDateTime lastActiveTime;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;

    /**
     * Cập nhật thời gian hoạt động gần nhất và Push Token mới.
     */
    public void recordActivity(String newPushToken, String appVersion) {
        if (newPushToken != null && !newPushToken.isBlank()) {
            this.pushToken = newPushToken;
        }
        if (appVersion != null && !appVersion.isBlank()) {
            this.appVersion = appVersion;
        }
        this.lastActiveTime = LocalDateTime.now();
        this.updatedTime = LocalDateTime.now();
    }

    /**
     * Khóa thiết bị an ninh.
     */
    public void block() {
        this.active = false;
        this.updatedTime = LocalDateTime.now();
    }

    /**
     * Mở khóa kích hoạt thiết bị.
     */
    public void unblock() {
        this.active = true;
        this.updatedTime = LocalDateTime.now();
    }
}
