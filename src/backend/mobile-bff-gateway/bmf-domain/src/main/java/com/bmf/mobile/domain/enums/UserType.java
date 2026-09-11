package com.bmf.mobile.domain.enums;

/**
 * Loại người dùng trong hệ sinh thái Mobile BMF.
 */
public enum UserType {
    AGENT("AGENT", "Cán bộ tín dụng thực địa"),
    CUSTOMER("CUSTOMER", "Khách hàng / Thành viên vi mô");

    private final String code;
    private final String description;

    UserType(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static UserType fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (UserType type : values()) {
            if (type.code.equalsIgnoreCase(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Invalid UserType code: " + code);
    }
}
