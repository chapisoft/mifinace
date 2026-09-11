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
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Thực thi MobileDeviceRepository truy vấn CSDL SQL Server 2017 bằng Spring 6 JdbcClient kèm memory fallback.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcMobileDeviceRepository implements MobileDeviceRepository {

    private final JdbcClient jdbcClient;
    private final Map<String, MobileDevice> memoryStore = new ConcurrentHashMap<>();

    private String buildKey(String deviceId, String userId) {
        return (deviceId != null ? deviceId : "") + "#" + (userId != null ? userId : "");
    }

    @Override
    public void save(MobileDevice device) {
        String key = buildKey(device.getDeviceId(), device.getUserId());
        memoryStore.put(key, device);

        try {
            String sql = """
                MERGE INTO dbo.SYS_MOBILE_DEVICE AS target
                USING (SELECT :deviceId AS Device_ID, :userId AS User_ID) AS source
                ON (target.Device_ID = source.Device_ID AND target.User_ID = source.User_ID)
                WHEN MATCHED THEN
                    UPDATE SET
                        User_Type = :userType,
                        Platform = :platform,
                        Device_Name = :deviceName,
                        OS_Version = :osVersion,
                        App_Version = :appVersion,
                        Push_Token = :pushToken,
                        Public_Key = :publicKey,
                        Is_Active = :isActive,
                        Last_Active_Time = :lastActiveTime,
                        Updated_Time = :updatedTime
                WHEN NOT MATCHED THEN
                    INSERT (Device_ID, User_ID, User_Type, Platform, Device_Name, OS_Version, App_Version, Push_Token, Public_Key, Is_Active, Last_Active_Time, Created_Time, Updated_Time)
                    VALUES (:deviceId, :userId, :userType, :platform, :deviceName, :osVersion, :appVersion, :pushToken, :publicKey, :isActive, :lastActiveTime, :createdTime, :updatedTime);
                """;

            jdbcClient.sql(sql)
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
            log.info("Saved mobile device to database: deviceId={}, userId={}", device.getDeviceId(), device.getUserId());
        } catch (Exception e) {
            log.debug("Database unavailable, saved mobile device in memory store: deviceId={}, userId={}",
                    device.getDeviceId(), device.getUserId());
        }
    }

    @Override
    public Optional<MobileDevice> findByDeviceIdAndUserId(String deviceId, String userId) {
        try {
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
        } catch (Exception e) {
            String key = buildKey(deviceId, userId);
            return Optional.ofNullable(memoryStore.get(key));
        }
    }

    @Override
    public List<MobileDevice> findActiveDevicesByUserId(String userId, UserType userType) {
        try {
            String sql = """
                SELECT Device_ID, User_ID, User_Type, Platform, Device_Name, OS_Version, App_Version,
                       Push_Token, Public_Key, Is_Active, Last_Active_Time, Created_Time, Updated_Time
                FROM dbo.SYS_MOBILE_DEVICE
                WHERE User_ID = :userId AND User_Type = :userType AND Is_Active = 1
                """;

            List<MobileDevice> list = jdbcClient.sql(sql)
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
            if (!list.isEmpty()) {
                return list;
            }
        } catch (Exception e) {
            log.debug("Querying active devices from memory fallback: {}", e.getMessage());
        }

        return memoryStore.values().stream()
                .filter(d -> userId.equals(d.getUserId()) && (userType == null || userType == d.getUserType()) && d.isActive())
                .collect(Collectors.toList());
    }

    @Override
    public List<String> findPushTokensByUserIds(List<String> userIds, UserType userType) {
        if (userIds == null || userIds.isEmpty()) {
            return Collections.emptyList();
        }

        try {
            String sql = """
                SELECT DISTINCT Push_Token
                FROM dbo.SYS_MOBILE_DEVICE
                WHERE User_ID IN (:userIds) AND User_Type = :userType AND Is_Active = 1 AND Push_Token IS NOT NULL
                """;

            List<String> tokens = jdbcClient.sql(sql)
                    .param("userIds", userIds)
                    .param("userType", userType.getCode())
                    .query((rs, rowNum) -> rs.getString("Push_Token"))
                    .list();
            if (!tokens.isEmpty()) {
                return tokens;
            }
        } catch (Exception e) {
            log.debug("Querying push tokens from memory fallback: {}", e.getMessage());
        }

        return memoryStore.values().stream()
                .filter(d -> userIds.contains(d.getUserId()) && (userType == null || userType == d.getUserType()) && d.isActive() && d.getPushToken() != null)
                .map(MobileDevice::getPushToken)
                .distinct()
                .collect(Collectors.toList());
    }

    @Override
    public void updateLastActiveTime(String deviceId, String userId) {
        String key = buildKey(deviceId, userId);
        MobileDevice device = memoryStore.get(key);
        if (device != null) {
            device.setLastActiveTime(LocalDateTime.now());
            device.setUpdatedTime(LocalDateTime.now());
        }

        try {
            String sql = """
                UPDATE dbo.SYS_MOBILE_DEVICE
                SET Last_Active_Time = GETDATE(), Updated_Time = GETDATE()
                WHERE Device_ID = :deviceId AND User_ID = :userId
                """;

            jdbcClient.sql(sql)
                    .param("deviceId", deviceId)
                    .param("userId", userId)
                    .update();
        } catch (Exception e) {
            log.debug("Updated last active time in memory store: deviceId={}, userId={}", deviceId, userId);
        }
    }

    @Override
    public void deactivateDevice(String deviceId, String userId) {
        String key = buildKey(deviceId, userId);
        MobileDevice device = memoryStore.get(key);
        if (device != null) {
            device.setActive(false);
            device.setUpdatedTime(LocalDateTime.now());
        }

        try {
            String sql = """
                UPDATE dbo.SYS_MOBILE_DEVICE
                SET Is_Active = 0, Updated_Time = GETDATE()
                WHERE Device_ID = :deviceId AND User_ID = :userId
                """;

            jdbcClient.sql(sql)
                    .param("deviceId", deviceId)
                    .param("userId", userId)
                    .update();
        } catch (Exception e) {
            log.debug("Deactivated device in memory store: deviceId={}, userId={}", deviceId, userId);
        }
    }
}
