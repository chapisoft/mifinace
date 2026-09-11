package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.CashHandover;
import com.bmf.mobile.domain.enums.CashHandoverStatus;
import com.bmf.mobile.domain.repository.CashHandoverRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Triển khai JDBC truy vấn bảng SYS_CASH_HANDOVER và tính toán dòng tiền thu trong ngày.
 */
@Repository
@RequiredArgsConstructor
public class JdbcCashHandoverRepository implements CashHandoverRepository {

    private final JdbcClient jdbcClient;

    @Override
    public void save(CashHandover handover) {
        String sql = """
            INSERT INTO dbo.SYS_CASH_HANDOVER (
                Handover_ID, Collector_ID, Handover_Date, Total_Amount,
                Total_Transactions, QR_Payload, QR_Signature, Status, Created_Time
            ) VALUES (
                :handoverId, :collectorId, :handoverDate, :totalAmount,
                :totalTransactions, :qrPayload, :qrSignature, :status, :createdTime
            )
            """;

        jdbcClient.sql(sql)
                .param("handoverId", handover.getHandoverId())
                .param("collectorId", handover.getCollectorId())
                .param("handoverDate", Date.valueOf(handover.getHandoverDate()))
                .param("totalAmount", handover.getTotalAmount())
                .param("totalTransactions", handover.getTotalTransactions())
                .param("qrPayload", handover.getQrPayload())
                .param("qrSignature", handover.getQrSignature())
                .param("status", handover.getStatus().name())
                .param("createdTime", Timestamp.valueOf(handover.getCreatedTime()))
                .update();
    }

    @Override
    public Optional<CashHandover> findById(String handoverId) {
        String sql = """
            SELECT Handover_ID, Collector_ID, Handover_Date, Total_Amount,
                   Total_Transactions, QR_Payload, QR_Signature, Status,
                   Created_Time, Confirmed_By, Confirmed_Time
            FROM dbo.SYS_CASH_HANDOVER
            WHERE Handover_ID = :handoverId
            """;

        return jdbcClient.sql(sql)
                .param("handoverId", handoverId)
                .query((rs, rowNum) -> CashHandover.builder()
                        .handoverId(rs.getString("Handover_ID"))
                        .collectorId(rs.getString("Collector_ID"))
                        .handoverDate(rs.getDate("Handover_Date").toLocalDate())
                        .totalAmount(rs.getBigDecimal("Total_Amount"))
                        .totalTransactions(rs.getInt("Total_Transactions"))
                        .qrPayload(rs.getString("QR_Payload"))
                        .qrSignature(rs.getString("QR_Signature"))
                        .status(CashHandoverStatus.valueOf(rs.getString("Status")))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .confirmedBy(rs.getString("Confirmed_By"))
                        .confirmedTime(rs.getTimestamp("Confirmed_Time") != null ? rs.getTimestamp("Confirmed_Time").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public List<CashHandover> findByCollectorId(String collectorId) {
        String sql = """
            SELECT Handover_ID, Collector_ID, Handover_Date, Total_Amount,
                   Total_Transactions, QR_Payload, QR_Signature, Status,
                   Created_Time, Confirmed_By, Confirmed_Time
            FROM dbo.SYS_CASH_HANDOVER
            WHERE Collector_ID = :collectorId
            ORDER BY Handover_Date DESC
            """;

        return jdbcClient.sql(sql)
                .param("collectorId", collectorId)
                .query((rs, rowNum) -> CashHandover.builder()
                        .handoverId(rs.getString("Handover_ID"))
                        .collectorId(rs.getString("Collector_ID"))
                        .handoverDate(rs.getDate("Handover_Date").toLocalDate())
                        .totalAmount(rs.getBigDecimal("Total_Amount"))
                        .totalTransactions(rs.getInt("Total_Transactions"))
                        .qrPayload(rs.getString("QR_Payload"))
                        .qrSignature(rs.getString("QR_Signature"))
                        .status(CashHandoverStatus.valueOf(rs.getString("Status")))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .confirmedBy(rs.getString("Confirmed_By"))
                        .confirmedTime(rs.getTimestamp("Confirmed_Time") != null ? rs.getTimestamp("Confirmed_Time").toLocalDateTime() : null)
                        .build())
                .list();
    }

    @Override
    public void updateStatus(String handoverId, CashHandoverStatus status, String confirmedBy) {
        String sql = """
            UPDATE dbo.SYS_CASH_HANDOVER
            SET Status = :status, Confirmed_By = :confirmedBy, Confirmed_Time = SYSUTCDATETIME()
            WHERE Handover_ID = :handoverId
            """;

        jdbcClient.sql(sql)
                .param("status", status.name())
                .param("confirmedBy", confirmedBy)
                .param("handoverId", handoverId)
                .update();
    }

    @Override
    public BigDecimal calculateTotalCashCollectedToday(String collectorId, LocalDate date) {
        String sql = """
            SELECT COALESCE(
                (SELECT SUM(Total_Amount) FROM dbo.SYS_REPAYMENT_TRANSACTION
                 WHERE Collected_By = :collectorId
                   AND Payment_Method = 'CASH'
                   AND CAST(Collected_Time AS DATE) = :date), 0)
            +
            COALESCE(
                (SELECT SUM(Amount) FROM dbo.SYS_SAVING_TRANSACTION
                 WHERE Collected_By = :collectorId
                   AND Payment_Method = 'CASH'
                   AND CAST(Collected_Time AS DATE) = :date), 0) AS Total_Cash
            """;

        return jdbcClient.sql(sql)
                .param("collectorId", collectorId)
                .param("date", Date.valueOf(date))
                .query(BigDecimal.class)
                .single();
    }

    @Override
    public int countTotalTransactionsToday(String collectorId, LocalDate date) {
        String sql = """
            SELECT COALESCE(
                (SELECT COUNT(*) FROM dbo.SYS_REPAYMENT_TRANSACTION
                 WHERE Collected_By = :collectorId
                   AND Payment_Method = 'CASH'
                   AND CAST(Collected_Time AS DATE) = :date), 0)
            +
            COALESCE(
                (SELECT COUNT(*) FROM dbo.SYS_SAVING_TRANSACTION
                 WHERE Collected_By = :collectorId
                   AND Payment_Method = 'CASH'
                   AND CAST(Collected_Time AS DATE) = :date), 0) AS Total_Count
            """;

        return jdbcClient.sql(sql)
                .param("collectorId", collectorId)
                .param("date", Date.valueOf(date))
                .query(Integer.class)
                .single();
    }
}
