package com.bmf.mobile.domain.enums;

/**
 * Nền tảng hệ điều hành thiết bị di động.
 */
public enum PlatformType {
    ANDROID("ANDROID", "Hệ điều hành Android"),
    IOS("IOS", "Hệ điều hành Apple iOS");

    private final String code;
    private final String description;

    PlatformType(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static PlatformType fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (PlatformType type : values()) {
            if (type.code.equalsIgnoreCase(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Invalid PlatformType code: " + code);
    }
}
