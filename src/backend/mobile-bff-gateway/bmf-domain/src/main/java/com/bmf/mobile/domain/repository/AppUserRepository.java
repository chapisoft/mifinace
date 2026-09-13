package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.AppUser;
import com.bmf.mobile.domain.enums.UserType;

import java.util.Optional;

/**
 * Interface Port cho việc quản lý bảng SYS_APP_USER.
 */
public interface AppUserRepository {

    Optional<AppUser> findByIdentifier(String identifier, UserType userType);

    Optional<AppUser> findByBusinessId(String businessId, UserType userType);

    Optional<AppUser> findByUserId(String userId);

    void save(AppUser appUser);

    void updateActivationAndPin(String userId, String pinHash, boolean biometricEnabled);

    void updatePin(String userId, String newPinHash);

    void recordLoginSuccess(String userId);

    void recordPinFailure(String userId, int failedAttempts);

    void resetPinFailure(String userId);
}
