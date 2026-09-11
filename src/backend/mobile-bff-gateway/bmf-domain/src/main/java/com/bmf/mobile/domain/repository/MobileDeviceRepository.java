package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.UserType;

import java.util.List;
import java.util.Optional;

/**
 * Interface Repository quản lý thiết bị di động trong CSDL.
 */
public interface MobileDeviceRepository {

    /**
     * Lưu hoặc cập nhật thông tin thiết bị.
     */
    void save(MobileDevice device);

    /**
     * Tìm kiếm thiết bị theo Device_ID và User_ID.
     */
    Optional<MobileDevice> findByDeviceIdAndUserId(String deviceId, String userId);

    /**
     * Tìm danh sách thiết bị đang hoạt động của một người dùng.
     */
    List<MobileDevice> findActiveDevicesByUserId(String userId, UserType userType);

    /**
     * Tìm danh sách Push Token đang hoạt động theo danh sách UserId.
     */
    List<String> findPushTokensByUserIds(List<String> userIds, UserType userType);

    /**
     * Cập nhật thời gian hoạt động gần nhất.
     */
    void updateLastActiveTime(String deviceId, String userId);

    /**
     * Vô hiệu hóa / Khóa thiết bị.
     */
    void deactivateDevice(String deviceId, String userId);
}
