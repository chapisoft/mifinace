package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.AppUser;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.repository.AppUserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Hiện thực AppUserRepository thao tác bảng SYS_APP_USER trên SQL Server bằng Spring JdbcClient.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcAppUserRepository implements AppUserRepository {

    private final JdbcClient jdbcClient;

    @Override
    public Optional<AppUser> findByIdentifier(String identifier, UserType userType) {
        String sql = """
            SELECT User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
                   Full_Name, Pin_Hash, Password_Hash, Is_Activated, Activated_Time,
                   Biometric_Enabled, Status, Failed_Pin_Attempts, Pin_Locked_Until,
                   Last_Login_Time, Created_Time, Updated_Time
            FROM dbo.SYS_APP_USER
            WHERE User_Type = :userType 
              AND (Identifier_Key = :identifier OR Phone_Number = :identifier OR Nrc_Number = :identifier)
            """;

        return jdbcClient.sql(sql)
                .param("userType", userType.name())
                .param("identifier", identifier)
                .query(this::mapRow)
                .optional();
    }

    @Override
    public Optional<AppUser> findByBusinessId(String businessId, UserType userType) {
        String sql = """
            SELECT User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
                   Full_Name, Pin_Hash, Password_Hash, Is_Activated, Activated_Time,
                   Biometric_Enabled, Status, Failed_Pin_Attempts, Pin_Locked_Until,
                   Last_Login_Time, Created_Time, Updated_Time
            FROM dbo.SYS_APP_USER
            WHERE Business_Id = :businessId AND User_Type = :userType
            """;

        return jdbcClient.sql(sql)
                .param("businessId", businessId)
                .param("userType", userType.name())
                .query(this::mapRow)
                .optional();
    }

    @Override
    public Optional<AppUser> findByUserId(String userId) {
        String sql = """
            SELECT User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
                   Full_Name, Pin_Hash, Password_Hash, Is_Activated, Activated_Time,
                   Biometric_Enabled, Status, Failed_Pin_Attempts, Pin_Locked_Until,
                   Last_Login_Time, Created_Time, Updated_Time
            FROM dbo.SYS_APP_USER
            WHERE User_Id = :userId
            """;

        return jdbcClient.sql(sql)
                .param("userId", userId)
                .query(this::mapRow)
                .optional();
    }

    @Override
    public void save(AppUser appUser) {
        String sql = """
            MERGE dbo.SYS_APP_USER AS target
            USING (SELECT :userId AS User_Id) AS source
            ON (target.User_Id = source.User_Id)
            WHEN MATCHED THEN
                UPDATE SET
                    Business_Id = :businessId,
                    Identifier_Key = :identifierKey,
                    Phone_Number = :phoneNumber,
                    Nrc_Number = :nrcNumber,
                    Full_Name = :fullName,
                    Pin_Hash = :pinHash,
                    Password_Hash = :passwordHash,
                    Is_Activated = :activated,
                    Activated_Time = :activatedTime,
                    Biometric_Enabled = :biometricEnabled,
                    Status = :status,
                    Failed_Pin_Attempts = :failedPinAttempts,
                    Pin_Locked_Until = :pinLockedUntil,
                    Last_Login_Time = :lastLoginTime,
                    Updated_Time = GETDATE()
            WHEN NOT MATCHED THEN
                INSERT (
                    User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
                    Full_Name, Pin_Hash, Password_Hash, Is_Activated, Activated_Time,
                    Biometric_Enabled, Status, Failed_Pin_Attempts, Pin_Locked_Until,
                    Last_Login_Time, Created_Time, Updated_Time
                ) VALUES (
                    :userId, :userType, :businessId, :identifierKey, :phoneNumber, :nrcNumber,
                    :fullName, :pinHash, :passwordHash, :activated, :activatedTime,
                    :biometricEnabled, :status, :failedPinAttempts, :pinLockedUntil,
                    :lastLoginTime, GETDATE(), GETDATE()
                );
            """;

        jdbcClient.sql(sql)
                .param("userId", appUser.getUserId())
                .param("userType", appUser.getUserType().name())
                .param("businessId", appUser.getBusinessId())
                .param("identifierKey", appUser.getIdentifierKey())
                .param("phoneNumber", appUser.getPhoneNumber())
                .param("nrcNumber", appUser.getNrcNumber())
                .param("fullName", appUser.getFullName())
                .param("pinHash", appUser.getPinHash())
                .param("passwordHash", appUser.getPasswordHash())
                .param("activated", appUser.isActivated() ? 1 : 0)
                .param("activatedTime", appUser.getActivatedTime() != null ? Timestamp.valueOf(appUser.getActivatedTime()) : null)
                .param("biometricEnabled", appUser.isBiometricEnabled() ? 1 : 0)
                .param("status", appUser.getStatus() != null ? appUser.getStatus() : "ACTIVE")
                .param("failedPinAttempts", appUser.getFailedPinAttempts())
                .param("pinLockedUntil", appUser.getPinLockedUntil() != null ? Timestamp.valueOf(appUser.getPinLockedUntil()) : null)
                .param("lastLoginTime", appUser.getLastLoginTime() != null ? Timestamp.valueOf(appUser.getLastLoginTime()) : null)
                .update();

        log.info("Saved AppUser to database: userId={}, businessId={}, userType={}, activated={}",
                appUser.getUserId(), appUser.getBusinessId(), appUser.getUserType(), appUser.isActivated());
    }

    @Override
    public void updateActivationAndPin(String userId, String pinHash, boolean biometricEnabled) {
        String sql = """
            UPDATE dbo.SYS_APP_USER
            SET Pin_Hash = :pinHash,
                Is_Activated = 1,
                Activated_Time = GETDATE(),
                Biometric_Enabled = :biometricEnabled,
                Failed_Pin_Attempts = 0,
                Pin_Locked_Until = NULL,
                Updated_Time = GETDATE()
            WHERE User_Id = :userId
            """;

        jdbcClient.sql(sql)
                .param("pinHash", pinHash)
                .param("biometricEnabled", biometricEnabled ? 1 : 0)
                .param("userId", userId)
                .update();

        log.info("Updated AppUser activation and PIN: userId={}, biometricEnabled={}", userId, biometricEnabled);
    }

    @Override
    public void updatePin(String userId, String newPinHash) {
        String sql = """
            UPDATE dbo.SYS_APP_USER
            SET Pin_Hash = :newPinHash,
                Failed_Pin_Attempts = 0,
                Pin_Locked_Until = NULL,
                Updated_Time = GETDATE()
            WHERE User_Id = :userId
            """;

        jdbcClient.sql(sql)
                .param("newPinHash", newPinHash)
                .param("userId", userId)
                .update();

        log.info("Updated AppUser PIN: userId={}", userId);
    }

    @Override
    public void recordLoginSuccess(String userId) {
        String sql = """
            UPDATE dbo.SYS_APP_USER
            SET Last_Login_Time = GETDATE(),
                Failed_Pin_Attempts = 0,
                Pin_Locked_Until = NULL,
                Updated_Time = GETDATE()
            WHERE User_Id = :userId
            """;

        jdbcClient.sql(sql)
                .param("userId", userId)
                .update();
    }

    @Override
    public void recordPinFailure(String userId, int failedAttempts) {
        LocalDateTime lockedUntil = failedAttempts >= 5 ? LocalDateTime.now().plusMinutes(15) : null;
        String sql = """
            UPDATE dbo.SYS_APP_USER
            SET Failed_Pin_Attempts = :failedAttempts,
                Pin_Locked_Until = :lockedUntil,
                Updated_Time = GETDATE()
            WHERE User_Id = :userId
            """;

        jdbcClient.sql(sql)
                .param("failedAttempts", failedAttempts)
                .param("lockedUntil", lockedUntil != null ? Timestamp.valueOf(lockedUntil) : null)
                .param("userId", userId)
                .update();
    }

    @Override
    public void resetPinFailure(String userId) {
        String sql = """
            UPDATE dbo.SYS_APP_USER
            SET Failed_Pin_Attempts = 0,
                Pin_Locked_Until = NULL,
                Updated_Time = GETDATE()
            WHERE User_Id = :userId
            """;

        jdbcClient.sql(sql)
                .param("userId", userId)
                .update();
    }

    private AppUser mapRow(ResultSet rs, int rowNum) throws SQLException {
        Timestamp activatedTs = rs.getTimestamp("Activated_Time");
        Timestamp lockedTs = rs.getTimestamp("Pin_Locked_Until");
        Timestamp lastLoginTs = rs.getTimestamp("Last_Login_Time");
        Timestamp createdTs = rs.getTimestamp("Created_Time");
        Timestamp updatedTs = rs.getTimestamp("Updated_Time");

        return AppUser.builder()
                .userId(rs.getString("User_Id"))
                .userType(UserType.valueOf(rs.getString("User_Type")))
                .businessId(rs.getString("Business_Id"))
                .identifierKey(rs.getString("Identifier_Key"))
                .phoneNumber(rs.getString("Phone_Number"))
                .nrcNumber(rs.getString("Nrc_Number"))
                .fullName(rs.getString("Full_Name"))
                .pinHash(rs.getString("Pin_Hash"))
                .passwordHash(rs.getString("Password_Hash"))
                .activated(rs.getInt("Is_Activated") == 1)
                .activatedTime(activatedTs != null ? activatedTs.toLocalDateTime() : null)
                .biometricEnabled(rs.getInt("Biometric_Enabled") == 1)
                .status(rs.getString("Status"))
                .failedPinAttempts(rs.getInt("Failed_Pin_Attempts"))
                .pinLockedUntil(lockedTs != null ? lockedTs.toLocalDateTime() : null)
                .lastLoginTime(lastLoginTs != null ? lastLoginTs.toLocalDateTime() : null)
                .createdTime(createdTs != null ? createdTs.toLocalDateTime() : null)
                .updatedTime(updatedTs != null ? updatedTs.toLocalDateTime() : null)
                .build();
    }
}
