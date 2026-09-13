package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

/**
 * Thực thi MobileDeviceRepository truy vấn CSDL SQL Server 2017 bằng Spring 6 JdbcClient kèm memory fallback.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcMobileDeviceRepository implements MobileDeviceRepository {

    private final JdbcClient jdbcClient;

    @Override
    public void save(MobileDevice device) {
        String updateSql = """
            UPDATE dbo.SYS_MOBILE_DEVICE
            SET User_Type = :userType,
                Platform = :platform,
                Device_Name = :deviceName,
                OS_Version = :osVersion,
                App_Version = :appVersion,
                Push_Token = :pushToken,
                Public_Key = :publicKey,
                Is_Active = :isActive,
                Last_Active_Time = :lastActiveTime,
                Updated_Time = :updatedTime
            WHERE Device_ID = :deviceId AND User_ID = :userId
            """;

        int rows = jdbcClient.sql(updateSql)
                .param("deviceId", device.getDeviceId())
                .param("userId", device.getUserId())
                .param("userType", device.getUserType().getCode())
                .param("platform", device.getPlatform().getCode())
                .param("deviceName", device.getDeviceName())
                .param("osVersion", device.getOsVersion())
                .param("appVersion", device.getAppVersion())
                .param("pushToken", device.getPushToken())
                .param("publicKey", device.getPublicKey())
                .param("isActive", device.isActive() ? 1 : 0)
                .param("lastActiveTime", Timestamp.valueOf(device.getLastActiveTime() != null ? device.getLastActiveTime() : LocalDateTime.now()))
                .param("updatedTime", Timestamp.valueOf(LocalDateTime.now()))
                .update();

        if (rows == 0) {
            String insertSql = """
                INSERT INTO dbo.SYS_MOBILE_DEVICE (
                    Device_ID, User_ID, User_Type, Platform, Device_Name, OS_Version,
                    App_Version, Push_Token, Public_Key, Is_Active, Last_Active_Time, Created_Time, Updated_Time
                ) VALUES (
                    :deviceId, :userId, :userType, :platform, :deviceName, :osVersion,
                    :appVersion, :pushToken, :publicKey, :isActive, :lastActiveTime, :createdTime, :updatedTime
                )
                """;

            jdbcClient.sql(insertSql)
                    .param("deviceId", device.getDeviceId())
                    .param("userId", device.getUserId())
                    .param("userType", device.getUserType().getCode())
                    .param("platform", device.getPlatform().getCode())
                    .param("deviceName", device.getDeviceName())
                    .param("osVersion", device.getOsVersion())
                    .param("appVersion", device.getAppVersion())
                    .param("pushToken", device.getPushToken())
                    .param("publicKey", device.getPublicKey())
                    .param("isActive", device.isActive() ? 1 : 0)
                    .param("lastActiveTime", Timestamp.valueOf(device.getLastActiveTime() != null ? device.getLastActiveTime() : LocalDateTime.now()))
                    .param("createdTime", Timestamp.valueOf(device.getCreatedTime() != null ? device.getCreatedTime() : LocalDateTime.now()))
                    .param("updatedTime", Timestamp.valueOf(LocalDateTime.now()))
                    .update();
        }

        log.info("Saved mobile device to database: deviceId={}, userId={}", device.getDeviceId(), device.getUserId());
    }

    @Override
    public Optional<MobileDevice> findByDeviceIdAndUserId(String deviceId, String userId) {
        String sql = """
            SELECT Device_ID, User_ID, User_Type, Platform, Device_Name, OS_Version, App_Version,
                   Push_Token, Public_Key, Is_Active, Last_Active_Time, Created_Time, Updated_Time
            FROM dbo.SYS_MOBILE_DEVICE
            WHERE Device_ID = :deviceId AND User_ID = :userId
            """;

        return jdbcClient.sql(sql)
                .param("deviceId", deviceId)
                .param("userId", userId)
                .query((rs, rowNum) -> MobileDevice.builder()
                        .deviceId(rs.getString("Device_ID"))
                        .userId(rs.getString("User_ID"))
                        .userType(UserType.fromCode(rs.getString("User_Type")))
                        .platform(PlatformType.fromCode(rs.getString("Platform")))
                        .deviceName(rs.getString("Device_Name"))
                        .osVersion(rs.getString("OS_Version"))
                        .appVersion(rs.getString("App_Version"))
                        .pushToken(rs.getString("Push_Token"))
                        .publicKey(rs.getString("Public_Key"))
                        .active(rs.getInt("Is_Active") == 1)
                        .lastActiveTime(rs.getTimestamp("Last_Active_Time") != null ? rs.getTimestamp("Last_Active_Time").toLocalDateTime() : null)
                        .createdTime(rs.getTimestamp("Created_Time") != null ? rs.getTimestamp("Created_Time").toLocalDateTime() : null)
                        .updatedTime(rs.getTimestamp("Updated_Time") != null ? rs.getTimestamp("Updated_Time").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public List<MobileDevice> findActiveDevicesByUserId(String userId, UserType userType) {
        String sql = """
            SELECT Device_ID, User_ID, User_Type, Platform, Device_Name, OS_Version, App_Version,
                   Push_Token, Public_Key, Is_Active, Last_Active_Time, Created_Time, Updated_Time
            FROM dbo.SYS_MOBILE_DEVICE
            WHERE User_ID = :userId AND User_Type = :userType AND Is_Active = 1
            """;

        return jdbcClient.sql(sql)
                .param("userId", userId)
                .param("userType", userType.getCode())
                .query((rs, rowNum) -> MobileDevice.builder()
                        .deviceId(rs.getString("Device_ID"))
                        .userId(rs.getString("User_ID"))
                        .userType(UserType.fromCode(rs.getString("User_Type")))
                        .platform(PlatformType.fromCode(rs.getString("Platform")))
                        .deviceName(rs.getString("Device_Name"))
                        .osVersion(rs.getString("OS_Version"))
                        .appVersion(rs.getString("App_Version"))
                        .pushToken(rs.getString("Push_Token"))
                        .publicKey(rs.getString("Public_Key"))
                        .active(rs.getInt("Is_Active") == 1)
                        .lastActiveTime(rs.getTimestamp("Last_Active_Time") != null ? rs.getTimestamp("Last_Active_Time").toLocalDateTime() : null)
                        .createdTime(rs.getTimestamp("Created_Time") != null ? rs.getTimestamp("Created_Time").toLocalDateTime() : null)
                        .updatedTime(rs.getTimestamp("Updated_Time") != null ? rs.getTimestamp("Updated_Time").toLocalDateTime() : null)
                        .build())
                .list();
    }

    @Override
    public List<String> findPushTokensByUserIds(List<String> userIds, UserType userType) {
        if (userIds == null || userIds.isEmpty()) {
            return Collections.emptyList();
        }

        String sql = """
            SELECT DISTINCT Push_Token
            FROM dbo.SYS_MOBILE_DEVICE
            WHERE User_ID IN (:userIds) AND User_Type = :userType AND Is_Active = 1 AND Push_Token IS NOT NULL
            """;

        return jdbcClient.sql(sql)
                .param("userIds", userIds)
                .param("userType", userType.getCode())
                .query((rs, rowNum) -> rs.getString("Push_Token"))
                .list();
    }

    @Override
    public void updateLastActiveTime(String deviceId, String userId) {
        String sql = """
            UPDATE dbo.SYS_MOBILE_DEVICE
            SET Last_Active_Time = GETDATE(), Updated_Time = GETDATE()
            WHERE Device_ID = :deviceId AND User_ID = :userId
            """;

        jdbcClient.sql(sql)
                .param("deviceId", deviceId)
                .param("userId", userId)
                .update();
    }

    @Override
    public void deactivateDevice(String deviceId, String userId) {
        String sql = """
            UPDATE dbo.SYS_MOBILE_DEVICE
            SET Is_Active = 0, Updated_Time = GETDATE()
            WHERE Device_ID = :deviceId AND User_ID = :userId
            """;

        jdbcClient.sql(sql)
                .param("deviceId", deviceId)
                .param("userId", userId)
                .update();
    }
}
