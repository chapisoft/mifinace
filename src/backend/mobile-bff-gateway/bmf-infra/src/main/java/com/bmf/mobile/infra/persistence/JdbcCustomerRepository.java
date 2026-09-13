package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Hiện thực CustomerRepository truy vấn bảng KH_THANHVIEN và kiểm tra vai trò Trưởng nhóm/Trưởng cụm trong DM_TO, DM_NHOM, DM_CUM.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcCustomerRepository implements CustomerRepository {

    private final JdbcClient jdbcClient;

    @Override
    public Optional<CustomerMember> findByNrcNumber(String nrcNumber) {
        String sql = """
            SELECT Ma_ThanhVien, Ten_ThanhVien, So_NRC, So_DienThoai, Ma_PIN, Ma_To, Ma_Cum, Township, Trang_Thai, Ngay_GiaNhap
            FROM dbo.KH_THANHVIEN
            WHERE So_NRC = :nrcNumber
            """;

        return jdbcClient.sql(sql)
                .param("nrcNumber", nrcNumber)
                .query((rs, rowNum) -> CustomerMember.builder()
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .fullName(rs.getString("Ten_ThanhVien"))
                        .nrcNumber(rs.getString("So_NRC"))
                        .phoneNumber(rs.getString("So_DienThoai"))
                        .pinHash(rs.getString("Ma_PIN"))
                        .groupCode(rs.getString("Ma_To"))
                        .centerCode(rs.getString("Ma_Cum"))
                        .township(rs.getString("Township"))
                        .active(rs.getInt("Trang_Thai") == 1)
                        .createdTime(rs.getTimestamp("Ngay_GiaNhap") != null ? rs.getTimestamp("Ngay_GiaNhap").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public Optional<CustomerMember> findByCustomerCode(String customerCode) {
        String sql = """
            SELECT Ma_ThanhVien, Ten_ThanhVien, So_NRC, So_DienThoai, Ma_PIN, Ma_To, Ma_Cum, Township, Trang_Thai, Ngay_GiaNhap
            FROM dbo.KH_THANHVIEN
            WHERE Ma_ThanhVien = :customerCode
            """;

        return jdbcClient.sql(sql)
                .param("customerCode", customerCode)
                .query((rs, rowNum) -> CustomerMember.builder()
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .fullName(rs.getString("Ten_ThanhVien"))
                        .nrcNumber(rs.getString("So_NRC"))
                        .phoneNumber(rs.getString("So_DienThoai"))
                        .pinHash(rs.getString("Ma_PIN"))
                        .groupCode(rs.getString("Ma_To"))
                        .centerCode(rs.getString("Ma_Cum"))
                        .township(rs.getString("Township"))
                        .active(rs.getInt("Trang_Thai") == 1)
                        .createdTime(rs.getTimestamp("Ngay_GiaNhap") != null ? rs.getTimestamp("Ngay_GiaNhap").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public Optional<CustomerMember> findByPhoneNumber(String phoneNumber) {
        String sql = """
            SELECT Ma_ThanhVien, Ten_ThanhVien, So_NRC, So_DienThoai, Ma_PIN, Ma_To, Ma_Cum, Township, Trang_Thai, Ngay_GiaNhap
            FROM dbo.KH_THANHVIEN
            WHERE So_DienThoai = :phoneNumber
            """;

        return jdbcClient.sql(sql)
                .param("phoneNumber", phoneNumber)
                .query((rs, rowNum) -> CustomerMember.builder()
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .fullName(rs.getString("Ten_ThanhVien"))
                        .nrcNumber(rs.getString("So_NRC"))
                        .phoneNumber(rs.getString("So_DienThoai"))
                        .pinHash(rs.getString("Ma_PIN"))
                        .groupCode(rs.getString("Ma_To"))
                        .centerCode(rs.getString("Ma_Cum"))
                        .township(rs.getString("Township"))
                        .active(rs.getInt("Trang_Thai") == 1)
                        .createdTime(rs.getTimestamp("Ngay_GiaNhap") != null ? rs.getTimestamp("Ngay_GiaNhap").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public void updatePinHash(String customerCode, String newPinHash) {
        String sql = """
            UPDATE dbo.KH_THANHVIEN
            SET Ma_PIN = :newPinHash, Ngay_CapNhat = GETDATE()
            WHERE Ma_ThanhVien = :customerCode
            """;

        jdbcClient.sql(sql)
                .param("newPinHash", newPinHash)
                .param("customerCode", customerCode)
                .update();
        log.info("Updated PIN hash for customer: customerCode={}", customerCode);
    }

    @Override
    public boolean isGroupOrCenterLeader(String customerCode, String fullName, String groupCode, String centerCode) {
        String sql = """
            SELECT COUNT(1) FROM (
                SELECT 1 AS matched FROM dbo.DM_TO 
                WHERE (Nhom_Truong = :customerCode OR Nhom_Truong = :fullName)
                UNION ALL
                SELECT 1 AS matched FROM dbo.DM_NHOM 
                WHERE MA_NHOM_TRUONG = :customerCode
                UNION ALL
                SELECT 1 AS matched FROM dbo.DM_CUM 
                WHERE (MA_CUM_TRUONG = :customerCode OR TEN_CUM_TRUONG = :fullName)
            ) t
            """;

        Integer count = jdbcClient.sql(sql)
                .param("customerCode", customerCode)
                .param("fullName", fullName != null ? fullName : "")
                .query((rs, rowNum) -> rs.getInt(1))
                .optional()
                .orElse(0);

        boolean isLeader = count > 0;
        log.info("Checked leader status: customerCode={}, fullName={}, isLeader={}", customerCode, fullName, isLeader);
        return isLeader;
    }
}
