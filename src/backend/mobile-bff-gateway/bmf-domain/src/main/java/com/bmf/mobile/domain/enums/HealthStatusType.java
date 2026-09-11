package com.bmf.mobile.domain.enums;

import lombok.Getter;

/**
 * Phân loại trạng thái sức khỏe dịch vụ hệ thống.
 * 100% Enum-Driven thay thế String literal "UP"/"DOWN".
 */
@Getter
public enum HealthStatusType {
    UP("UP", "Hoạt động bình thường"),
    DOWN("DOWN", "Dừng hoạt động"),
    DEGRADED("DEGRADED", "Hiệu năng suy giảm");

    private final String code;
    private final String description;

    HealthStatusType(String code, String description) {
        this.code = code;
        this.description = description;
    }
}
