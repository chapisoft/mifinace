package com.bmf.mobile.domain.enums;

/**
 * Trạng thái thiết bị di động.
 */
public enum DeviceStatus {
    ACTIVE(1, "Hoạt động"),
    BLOCKED(0, "Bị khóa");

    private final int value;
    private final String description;

    DeviceStatus(int value, String description) {
        this.value = value;
        this.description = description;
    }

    public int getValue() {
        return value;
    }

    public String getDescription() {
        return description;
    }

    public static DeviceStatus fromValue(int value) {
        for (DeviceStatus status : values()) {
            if (status.value == value) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid DeviceStatus value: " + value);
    }
}
