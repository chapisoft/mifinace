package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.repository.LoanRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Triển khai LoanRepository truy vấn bảng TD_LICH_THUNO và TD_HOPDONG bằng Spring 6 JdbcClient.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcLoanRepository implements LoanRepository {

    private final JdbcClient jdbcClient;

    @Override
    public List<GroupScheduleRecord> findSchedulesByGroupCodeAndDate(String groupCode, LocalDate dueDate) {
        String sql = """
            SELECT l.Ma_HopDong, h.Ma_ThanhVien, k.Ten_ThanhVien, h.Ma_To, l.Ky_Thu,
                   l.Tien_Goc, l.Tien_Lai, l.Phi_BaoHiem, l.TietKiem_BatBuoc, l.Tong_Tien,
                   l.Ngay_DenHan, l.Trang_Thai
            FROM dbo.TD_LICH_THUNO l
            INNER JOIN dbo.TD_HOPDONG h ON l.Ma_HopDong = h.Ma_HopDong
            INNER JOIN dbo.KH_THANHVIEN k ON h.Ma_ThanhVien = k.Ma_ThanhVien
            WHERE h.Ma_To = :groupCode AND (l.Ngay_DenHan = :dueDate OR l.Trang_Thai IN ('DUE_TODAY', 'OVERDUE', 'PENDING'))
            ORDER BY k.Ten_ThanhVien ASC, l.Ky_Thu ASC
            """;

        return jdbcClient.sql(sql)
                .param("groupCode", groupCode)
                .param("dueDate", Date.valueOf(dueDate))
                .query((rs, rowNum) -> GroupScheduleRecord.builder()
                        .contractCode(rs.getString("Ma_HopDong"))
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .customerName(rs.getString("Ten_ThanhVien"))
                        .groupCode(rs.getString("Ma_To"))
                        .periodNumber(rs.getInt("Ky_Thu"))
                        .principalAmount(rs.getBigDecimal("Tien_Goc"))
                        .interestAmount(rs.getBigDecimal("Tien_Lai"))
                        .insuranceFee(rs.getBigDecimal("Phi_BaoHiem"))
                        .compulsorySaving(rs.getBigDecimal("TietKiem_BatBuoc"))
                        .totalAmount(rs.getBigDecimal("Tong_Tien"))
                        .dueDate(rs.getDate("Ngay_DenHan") != null ? rs.getDate("Ngay_DenHan").toLocalDate() : null)
                        .status(rs.getString("Trang_Thai"))
                        .build())
                .list();
    }

    @Override
    public List<GroupScheduleRecord> findSchedulesByContractCode(String contractCode) {
        String sql = """
            SELECT l.Ma_HopDong, h.Ma_ThanhVien, k.Ten_ThanhVien, h.Ma_To, l.Ky_Thu,
                   l.Tien_Goc, l.Tien_Lai, l.Phi_BaoHiem, l.TietKiem_BatBuoc, l.Tong_Tien,
                   l.Ngay_DenHan, l.Trang_Thai
            FROM dbo.TD_LICH_THUNO l
            INNER JOIN dbo.TD_HOPDONG h ON l.Ma_HopDong = h.Ma_HopDong
            INNER JOIN dbo.KH_THANHVIEN k ON h.Ma_ThanhVien = k.Ma_ThanhVien
            WHERE l.Ma_HopDong = :contractCode
            ORDER BY l.Ky_Thu ASC
            """;

        return jdbcClient.sql(sql)
                .param("contractCode", contractCode)
                .query((rs, rowNum) -> GroupScheduleRecord.builder()
                        .contractCode(rs.getString("Ma_HopDong"))
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .customerName(rs.getString("Ten_ThanhVien"))
                        .groupCode(rs.getString("Ma_To"))
                        .periodNumber(rs.getInt("Ky_Thu"))
                        .principalAmount(rs.getBigDecimal("Tien_Goc"))
                        .interestAmount(rs.getBigDecimal("Tien_Lai"))
                        .insuranceFee(rs.getBigDecimal("Phi_BaoHiem"))
                        .compulsorySaving(rs.getBigDecimal("TietKiem_BatBuoc"))
                        .totalAmount(rs.getBigDecimal("Tong_Tien"))
                        .dueDate(rs.getDate("Ngay_DenHan") != null ? rs.getDate("Ngay_DenHan").toLocalDate() : null)
                        .status(rs.getString("Trang_Thai"))
                        .build())
                .list();
    }

    @Override
    public List<GroupScheduleRecord> findSchedulesByCustomerCode(String customerCode) {
        String sql = """
            SELECT l.Ma_HopDong, h.Ma_ThanhVien, k.Ten_ThanhVien, h.Ma_To, l.Ky_Thu,
                   l.Tien_Goc, l.Tien_Lai, l.Phi_BaoHiem, l.TietKiem_BatBuoc, l.Tong_Tien,
                   l.Ngay_DenHan, l.Trang_Thai
            FROM dbo.TD_LICH_THUNO l
            INNER JOIN dbo.TD_HOPDONG h ON l.Ma_HopDong = h.Ma_HopDong
            INNER JOIN dbo.KH_THANHVIEN k ON h.Ma_ThanhVien = k.Ma_ThanhVien
            WHERE h.Ma_ThanhVien = :customerCode
            ORDER BY l.Ma_HopDong ASC, l.Ky_Thu ASC
            """;

        return jdbcClient.sql(sql)
                .param("customerCode", customerCode)
                .query((rs, rowNum) -> GroupScheduleRecord.builder()
                        .contractCode(rs.getString("Ma_HopDong"))
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .customerName(rs.getString("Ten_ThanhVien"))
                        .groupCode(rs.getString("Ma_To"))
                        .periodNumber(rs.getInt("Ky_Thu"))
                        .principalAmount(rs.getBigDecimal("Tien_Goc"))
                        .interestAmount(rs.getBigDecimal("Tien_Lai"))
                        .insuranceFee(rs.getBigDecimal("Phi_BaoHiem"))
                        .compulsorySaving(rs.getBigDecimal("TietKiem_BatBuoc"))
                        .totalAmount(rs.getBigDecimal("Tong_Tien"))
                        .dueDate(rs.getDate("Ngay_DenHan") != null ? rs.getDate("Ngay_DenHan").toLocalDate() : null)
                        .status(rs.getString("Trang_Thai"))
                        .build())
                .list();
    }

    @Override
    public Optional<GroupScheduleRecord> findScheduleByContractAndPeriod(String contractCode, int periodNumber) {
        String sql = """
            SELECT l.Ma_HopDong, h.Ma_ThanhVien, k.Ten_ThanhVien, h.Ma_To, l.Ky_Thu,
                   l.Tien_Goc, l.Tien_Lai, l.Phi_BaoHiem, l.TietKiem_BatBuoc, l.Tong_Tien,
                   l.Ngay_DenHan, l.Trang_Thai
            FROM dbo.TD_LICH_THUNO l
            INNER JOIN dbo.TD_HOPDONG h ON l.Ma_HopDong = h.Ma_HopDong
            INNER JOIN dbo.KH_THANHVIEN k ON h.Ma_ThanhVien = k.Ma_ThanhVien
            WHERE l.Ma_HopDong = :contractCode AND l.Ky_Thu = :periodNumber
            """;

        return jdbcClient.sql(sql)
                .param("contractCode", contractCode)
                .param("periodNumber", periodNumber)
                .query((rs, rowNum) -> GroupScheduleRecord.builder()
                        .contractCode(rs.getString("Ma_HopDong"))
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .customerName(rs.getString("Ten_ThanhVien"))
                        .groupCode(rs.getString("Ma_To"))
                        .periodNumber(rs.getInt("Ky_Thu"))
                        .principalAmount(rs.getBigDecimal("Tien_Goc"))
                        .interestAmount(rs.getBigDecimal("Tien_Lai"))
                        .insuranceFee(rs.getBigDecimal("Phi_BaoHiem"))
                        .compulsorySaving(rs.getBigDecimal("TietKiem_BatBuoc"))
                        .totalAmount(rs.getBigDecimal("Tong_Tien"))
                        .dueDate(rs.getDate("Ngay_DenHan") != null ? rs.getDate("Ngay_DenHan").toLocalDate() : null)
                        .status(rs.getString("Trang_Thai"))
                        .build())
                .optional();
    }

    @Override
    public List<GroupScheduleRecord> findSchedulesDueBetween(LocalDate fromDate, LocalDate toDate) {
        String sql = """
            SELECT l.Ma_HopDong, h.Ma_ThanhVien, k.Ten_ThanhVien, h.Ma_To, l.Ky_Thu,
                   l.Tien_Goc, l.Tien_Lai, l.Phi_BaoHiem, l.TietKiem_BatBuoc, l.Tong_Tien,
                   l.Ngay_DenHan, l.Trang_Thai
            FROM dbo.TD_LICH_THUNO l
            INNER JOIN dbo.TD_HOPDONG h ON l.Ma_HopDong = h.Ma_HopDong
            INNER JOIN dbo.KH_THANHVIEN k ON h.Ma_ThanhVien = k.Ma_ThanhVien
            WHERE l.Ngay_DenHan >= :fromDate AND l.Ngay_DenHan <= :toDate
              AND (l.Trang_Thai IS NULL OR l.Trang_Thai NOT IN ('SETTLED', 'PAID'))
            ORDER BY l.Ngay_DenHan ASC, k.Ten_ThanhVien ASC
            """;

        return jdbcClient.sql(sql)
                .param("fromDate", Date.valueOf(fromDate))
                .param("toDate", Date.valueOf(toDate))
                .query((rs, rowNum) -> GroupScheduleRecord.builder()
                        .contractCode(rs.getString("Ma_HopDong"))
                        .customerCode(rs.getString("Ma_ThanhVien"))
                        .customerName(rs.getString("Ten_ThanhVien"))
                        .groupCode(rs.getString("Ma_To"))
                        .periodNumber(rs.getInt("Ky_Thu"))
                        .principalAmount(rs.getBigDecimal("Tien_Goc"))
                        .interestAmount(rs.getBigDecimal("Tien_Lai"))
                        .insuranceFee(rs.getBigDecimal("Phi_BaoHiem"))
                        .compulsorySaving(rs.getBigDecimal("TietKiem_BatBuoc"))
                        .totalAmount(rs.getBigDecimal("Tong_Tien"))
                        .dueDate(rs.getDate("Ngay_DenHan") != null ? rs.getDate("Ngay_DenHan").toLocalDate() : null)
                        .status(rs.getString("Trang_Thai"))
                        .build())
                .list();
    }

    @Override
    public void updateScheduleStatus(String contractCode, int periodNumber, String status, BigDecimal collectedAmount) {
        String sql = """
            UPDATE dbo.TD_LICH_THUNO
            SET Trang_Thai = :status
            WHERE Ma_HopDong = :contractCode AND Ky_Thu = :periodNumber
            """;

        try {
            jdbcClient.sql(sql)
                    .param("status", status)
                    .param("contractCode", contractCode)
                    .param("periodNumber", periodNumber)
                    .update();
            log.info("Updated loan schedule status: contract={}, period={}, status={}", contractCode, periodNumber, status);
        } catch (Exception e) {
            log.warn("Failed to update loan schedule status in database: {}", e.getMessage());
        }
    }
}
