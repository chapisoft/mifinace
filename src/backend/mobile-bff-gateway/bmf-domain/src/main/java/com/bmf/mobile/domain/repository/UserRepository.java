package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.SysUser;

import java.util.Optional;

/**
 * Cổng giao tiếp truy xuất dữ liệu tài khoản người dùng nội bộ (Cán bộ tín dụng).
 */
public interface UserRepository {

    /**
     * Tìm kiếm người dùng theo tên đăng nhập (Username).
     */
    Optional<SysUser> findByUsername(String username);

    /**
     * Tìm kiếm người dùng theo mã định danh (UserId).
     */
    Optional<SysUser> findById(String userId);
}
