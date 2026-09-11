package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.RepaymentTransaction;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.repository.RepaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

/**
 * Triển khai RepaymentRepository lưu trữ giao dịch gạch nợ vào bảng SYS_REPAYMENT_TRANSACTION.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcRepaymentRepository implements RepaymentRepository {

    private final JdbcClient jdbcClient;

    @Override
    public RepaymentTransaction save(RepaymentTransaction tx) {
        String sql = """
            MERGE dbo.SYS_REPAYMENT_TRANSACTION AS target
            USING (SELECT :transactionId AS Transaction_ID) AS source
            ON (target.Transaction_ID = source.Transaction_ID)
            WHEN MATCHED THEN
                UPDATE SET
                    Status = :status,
                    Synced_Time = :syncedTime,
                    Notes = :notes
            WHEN NOT MATCHED THEN
                INSERT (Transaction_ID, Contract_Code, Customer_Code, Customer_Name, Group_Code,
                        Period_Number, Principal_Amount, Interest_Amount, Insurance_Fee,
                        Compulsory_Saving, Penalty_Amount, Total_Amount, Payment_Method,
                        Idempotency_Key, Collected_By, Collected_Time, Synced_Time, Status, Notes)
                VALUES (:transactionId, :contractCode, :customerCode, :customerName, :groupCode,
                        :periodNumber, :principalAmount, :interestAmount, :insuranceFee,
                        :compulsorySaving, :penaltyAmount, :totalAmount, :paymentMethod,
                        :idempotencyKey, :collectedBy, :collectedTime, :syncedTime, :status, :notes);
            """;

        jdbcClient.sql(sql)
                .param("transactionId", tx.getTransactionId())
                .param("contractCode", tx.getContractCode())
                .param("customerCode", tx.getCustomerCode())
                .param("customerName", tx.getCustomerName())
                .param("groupCode", tx.getGroupCode())
                .param("periodNumber", tx.getPeriodNumber())
                .param("principalAmount", tx.getPrincipalAmount())
                .param("interestAmount", tx.getInterestAmount())
                .param("insuranceFee", tx.getInsuranceFee())
                .param("compulsorySaving", tx.getCompulsorySaving())
                .param("penaltyAmount", tx.getPenaltyAmount())
                .param("totalAmount", tx.getTotalAmount())
                .param("paymentMethod", tx.getPaymentMethod().name())
                .param("idempotencyKey", tx.getIdempotencyKey())
                .param("collectedBy", tx.getCollectedBy())
                .param("collectedTime", Timestamp.valueOf(tx.getCollectedTime()))
                .param("syncedTime", Timestamp.valueOf(tx.getSyncedTime()))
                .param("status", tx.getStatus().name())
                .param("notes", tx.getNotes())
                .update();

        log.info("Saved repayment transaction: txId={}, contract={}, amount={}",
                tx.getTransactionId(), tx.getContractCode(), tx.getTotalAmount());
        return tx;
    }

    @Override
    public Optional<RepaymentTransaction> findById(String transactionId) {
        String sql = "SELECT * FROM dbo.SYS_REPAYMENT_TRANSACTION WHERE Transaction_ID = :transactionId";
        return jdbcClient.sql(sql)
                .param("transactionId", transactionId)
                .query(this::mapRowToTransaction)
                .optional();
    }

    @Override
    public Optional<RepaymentTransaction> findByIdempotencyKey(String idempotencyKey) {
        String sql = "SELECT * FROM dbo.SYS_REPAYMENT_TRANSACTION WHERE Idempotency_Key = :idempotencyKey";
        return jdbcClient.sql(sql)
                .param("idempotencyKey", idempotencyKey)
                .query(this::mapRowToTransaction)
                .optional();
    }

    @Override
    public List<RepaymentTransaction> findByContractCodeAndPeriod(String contractCode, int periodNumber) {
        String sql = "SELECT * FROM dbo.SYS_REPAYMENT_TRANSACTION WHERE Contract_Code = :contractCode AND Period_Number = :periodNumber";
        return jdbcClient.sql(sql)
                .param("contractCode", contractCode)
                .param("periodNumber", periodNumber)
                .query(this::mapRowToTransaction)
                .list();
    }

    @Override
    public List<RepaymentTransaction> findByCollectedByAndDate(String collectedBy, String date) {
        String sql = "SELECT * FROM dbo.SYS_REPAYMENT_TRANSACTION WHERE Collected_By = :collectedBy AND CAST(Collected_Time AS DATE) = :date";
        return jdbcClient.sql(sql)
                .param("collectedBy", collectedBy)
                .param("date", date)
                .query(this::mapRowToTransaction)
                .list();
    }

    private RepaymentTransaction mapRowToTransaction(java.sql.ResultSet rs, int rowNum) throws java.sql.SQLException {
        return RepaymentTransaction.builder()
                .transactionId(rs.getString("Transaction_ID"))
                .contractCode(rs.getString("Contract_Code"))
                .customerCode(rs.getString("Customer_Code"))
                .customerName(rs.getString("Customer_Name"))
                .groupCode(rs.getString("Group_Code"))
                .periodNumber(rs.getInt("Period_Number"))
                .principalAmount(rs.getBigDecimal("Principal_Amount"))
                .interestAmount(rs.getBigDecimal("Interest_Amount"))
                .insuranceFee(rs.getBigDecimal("Insurance_Fee"))
                .compulsorySaving(rs.getBigDecimal("Compulsory_Saving"))
                .penaltyAmount(rs.getBigDecimal("Penalty_Amount"))
                .totalAmount(rs.getBigDecimal("Total_Amount"))
                .paymentMethod(RepaymentMethod.valueOf(rs.getString("Payment_Method")))
                .idempotencyKey(rs.getString("Idempotency_Key"))
                .collectedBy(rs.getString("Collected_By"))
                .collectedTime(rs.getTimestamp("Collected_Time") != null ? rs.getTimestamp("Collected_Time").toLocalDateTime() : null)
                .syncedTime(rs.getTimestamp("Synced_Time") != null ? rs.getTimestamp("Synced_Time").toLocalDateTime() : null)
                .status(RepaymentStatus.valueOf(rs.getString("Status")))
                .notes(rs.getString("Notes"))
                .build();
    }
}
