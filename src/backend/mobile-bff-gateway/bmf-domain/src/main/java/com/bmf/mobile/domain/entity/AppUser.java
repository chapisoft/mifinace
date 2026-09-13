package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.UserType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho tài khoản ứng dụng di động trong bảng SYS_APP_USER.
 * Mapping 1-1 với hồ sơ thành viên (KH_THANHVIEN) hoặc cán bộ (HT_NSD).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = {"pinHash", "passwordHash"})
public class AppUser {

    private String userId;
    private UserType userType;
    private String businessId;
    private String identifierKey;
    private String phoneNumber;
    private String nrcNumber;
    private String fullName;
    private String pinHash;
    private String passwordHash;
    private boolean activated;
    private LocalDateTime activatedTime;
    private boolean biometricEnabled;
    private String status;
    private int failedPinAttempts;
    private LocalDateTime pinLockedUntil;
    private LocalDateTime lastLoginTime;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.status);
    }
}
