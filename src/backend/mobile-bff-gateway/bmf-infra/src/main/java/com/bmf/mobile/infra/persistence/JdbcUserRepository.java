package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.SysUser;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Hiện thực UserRepository truy vấn bảng HT_NGUOIDUNG bằng Spring 6 JdbcClient.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcUserRepository implements UserRepository {

    private final JdbcClient jdbcClient;

    @Override
    public Optional<SysUser> findByUsername(String username) {
        String sql = """
            SELECT Ma_NguoiDung, Ten_DangNhap, Ten_DayDu, Mat_Khau, Ma_ChiNhanh, Email, So_DienThoai, Trang_Thai, Ngay_Tao
            FROM dbo.HT_NGUOIDUNG
            WHERE Ten_DangNhap = :username
            """;

        return jdbcClient.sql(sql)
                .param("username", username)
                .query((rs, rowNum) -> SysUser.builder()
                        .userId(rs.getString("Ma_NguoiDung"))
                        .username(rs.getString("Ten_DangNhap"))
                        .fullName(rs.getString("Ten_DayDu"))
                        .passwordHash(rs.getString("Mat_Khau"))
                        .branchCode(rs.getString("Ma_ChiNhanh"))
                        .email(rs.getString("Email"))
                        .phoneNumber(rs.getString("So_DienThoai"))
                        .active(rs.getInt("Trang_Thai") == 1)
                        .userType(UserType.AGENT)
                        .createdTime(rs.getTimestamp("Ngay_Tao") != null ? rs.getTimestamp("Ngay_Tao").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public Optional<SysUser> findById(String userId) {
        String sql = """
            SELECT Ma_NguoiDung, Ten_DangNhap, Ten_DayDu, Mat_Khau, Ma_ChiNhanh, Email, So_DienThoai, Trang_Thai, Ngay_Tao
            FROM dbo.HT_NGUOIDUNG
            WHERE Ma_NguoiDung = :userId
            """;

        return jdbcClient.sql(sql)
                .param("userId", userId)
                .query((rs, rowNum) -> SysUser.builder()
                        .userId(rs.getString("Ma_NguoiDung"))
                        .username(rs.getString("Ten_DangNhap"))
                        .fullName(rs.getString("Ten_DayDu"))
                        .passwordHash(rs.getString("Mat_Khau"))
                        .branchCode(rs.getString("Ma_ChiNhanh"))
                        .email(rs.getString("Email"))
                        .phoneNumber(rs.getString("So_DienThoai"))
                        .active(rs.getInt("Trang_Thai") == 1)
                        .userType(UserType.AGENT)
                        .createdTime(rs.getTimestamp("Ngay_Tao") != null ? rs.getTimestamp("Ngay_Tao").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public Optional<SysUser> findByPhoneNumber(String phoneNumber) {
        String sql = """
            SELECT Ma_NguoiDung, Ten_DangNhap, Ten_DayDu, Mat_Khau, Ma_ChiNhanh, Email, So_DienThoai, Trang_Thai, Ngay_Tao
            FROM dbo.HT_NGUOIDUNG
            WHERE So_DienThoai = :phoneNumber
            """;

        return jdbcClient.sql(sql)
                .param("phoneNumber", phoneNumber)
                .query((rs, rowNum) -> SysUser.builder()
                        .userId(rs.getString("Ma_NguoiDung"))
                        .username(rs.getString("Ten_DangNhap"))
                        .fullName(rs.getString("Ten_DayDu"))
                        .passwordHash(rs.getString("Mat_Khau"))
                        .branchCode(rs.getString("Ma_ChiNhanh"))
                        .email(rs.getString("Email"))
                        .phoneNumber(rs.getString("So_DienThoai"))
                        .active(rs.getInt("Trang_Thai") == 1)
                        .userType(UserType.AGENT)
                        .createdTime(rs.getTimestamp("Ngay_Tao") != null ? rs.getTimestamp("Ngay_Tao").toLocalDateTime() : null)
                        .build())
                .optional();
    }
}
