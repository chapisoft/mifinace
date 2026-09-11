package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Hiện thực CustomerRepository truy vấn bảng KH_THANHVIEN bằng Spring 6 JdbcClient.
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
}
