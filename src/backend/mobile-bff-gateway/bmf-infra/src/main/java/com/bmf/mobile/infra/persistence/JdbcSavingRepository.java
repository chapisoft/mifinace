package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.SavingAccount;
import com.bmf.mobile.domain.entity.SavingTransaction;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingProductType;
import com.bmf.mobile.domain.enums.SavingTransactionType;
import com.bmf.mobile.domain.repository.SavingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

/**
 * Triển khai JDBC truy vấn bảng SYS_SAVING_ACCOUNT và SYS_SAVING_TRANSACTION trên SQL Server.
 */
@Repository
@RequiredArgsConstructor
public class JdbcSavingRepository implements SavingRepository {

    private final JdbcClient jdbcClient;

    @Override
    public void saveAccount(SavingAccount account) {
        String sql = """
            INSERT INTO dbo.SYS_SAVING_ACCOUNT (
                Account_Number, Customer_Code, Customer_Name, Product_Type,
                Balance, Interest_Rate, Term_Months, Beneficiary_Name, Beneficiary_NRC,
                Status, Created_By, Created_Time
            ) VALUES (
                :accountNumber, :customerCode, :customerName, :productType,
                :balance, :interestRate, :termMonths, :beneficiaryName, :beneficiaryNrc,
                :status, :createdBy, :createdTime
            )
            """;

        jdbcClient.sql(sql)
                .param("accountNumber", account.getAccountNumber())
                .param("customerCode", account.getCustomerCode())
                .param("customerName", account.getCustomerName())
                .param("productType", account.getProductType().name())
                .param("balance", account.getBalance())
                .param("interestRate", account.getInterestRate())
                .param("termMonths", account.getTermMonths())
                .param("beneficiaryName", account.getBeneficiaryName())
                .param("beneficiaryNrc", account.getBeneficiaryNrc())
                .param("status", account.getStatus().name())
                .param("createdBy", account.getCreatedBy())
                .param("createdTime", Timestamp.valueOf(account.getCreatedTime()))
                .update();
    }

    @Override
    public Optional<SavingAccount> findAccountByNumber(String accountNumber) {
        String sql = """
            SELECT Account_Number, Customer_Code, Customer_Name, Product_Type,
                   Balance, Interest_Rate, Term_Months, Beneficiary_Name, Beneficiary_NRC,
                   Status, Created_By, Created_Time, Updated_Time
            FROM dbo.SYS_SAVING_ACCOUNT
            WHERE Account_Number = :accountNumber
            """;

        return jdbcClient.sql(sql)
                .param("accountNumber", accountNumber)
                .query((rs, rowNum) -> SavingAccount.builder()
                        .accountNumber(rs.getString("Account_Number"))
                        .customerCode(rs.getString("Customer_Code"))
                        .customerName(rs.getString("Customer_Name"))
                        .productType(SavingProductType.valueOf(rs.getString("Product_Type")))
                        .balance(rs.getBigDecimal("Balance"))
                        .interestRate(rs.getBigDecimal("Interest_Rate"))
                        .termMonths(rs.getInt("Term_Months"))
                        .beneficiaryName(rs.getString("Beneficiary_Name"))
                        .beneficiaryNrc(rs.getString("Beneficiary_NRC"))
                        .status(SavingAccountStatus.valueOf(rs.getString("Status")))
                        .createdBy(rs.getString("Created_By"))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .updatedTime(rs.getTimestamp("Updated_Time") != null ? rs.getTimestamp("Updated_Time").toLocalDateTime() : null)
                        .build())
                .optional();
    }

    @Override
    public List<SavingAccount> findAccountsByCustomerCode(String customerCode) {
        String sql = """
            SELECT Account_Number, Customer_Code, Customer_Name, Product_Type,
                   Balance, Interest_Rate, Term_Months, Beneficiary_Name, Beneficiary_NRC,
                   Status, Created_By, Created_Time, Updated_Time
            FROM dbo.SYS_SAVING_ACCOUNT
            WHERE Customer_Code = :customerCode
            ORDER BY Created_Time DESC
            """;

        return jdbcClient.sql(sql)
                .param("customerCode", customerCode)
                .query((rs, rowNum) -> SavingAccount.builder()
                        .accountNumber(rs.getString("Account_Number"))
                        .customerCode(rs.getString("Customer_Code"))
                        .customerName(rs.getString("Customer_Name"))
                        .productType(SavingProductType.valueOf(rs.getString("Product_Type")))
                        .balance(rs.getBigDecimal("Balance"))
                        .interestRate(rs.getBigDecimal("Interest_Rate"))
                        .termMonths(rs.getInt("Term_Months"))
                        .beneficiaryName(rs.getString("Beneficiary_Name"))
                        .beneficiaryNrc(rs.getString("Beneficiary_NRC"))
                        .status(SavingAccountStatus.valueOf(rs.getString("Status")))
                        .createdBy(rs.getString("Created_By"))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .updatedTime(rs.getTimestamp("Updated_Time") != null ? rs.getTimestamp("Updated_Time").toLocalDateTime() : null)
                        .build())
                .list();
    }

    @Override
    public void updateAccountBalance(String accountNumber, BigDecimal newBalance) {
        String sql = """
            UPDATE dbo.SYS_SAVING_ACCOUNT
            SET Balance = :newBalance, Updated_Time = SYSUTCDATETIME()
            WHERE Account_Number = :accountNumber
            """;

        jdbcClient.sql(sql)
                .param("newBalance", newBalance)
                .param("accountNumber", accountNumber)
                .update();
    }

    @Override
    public void saveTransaction(SavingTransaction tx) {
        String sql = """
            INSERT INTO dbo.SYS_SAVING_TRANSACTION (
                Transaction_ID, Account_Number, Customer_Code, Amount,
                Transaction_Type, Payment_Method, Collected_By, Idempotency_Key,
                Collected_Time, Status, Created_Time
            ) VALUES (
                :transactionId, :accountNumber, :customerCode, :amount,
                :transactionType, :paymentMethod, :collectedBy, :idempotencyKey,
                :collectedTime, :status, :createdTime
            )
            """;

        jdbcClient.sql(sql)
                .param("transactionId", tx.getTransactionId())
                .param("accountNumber", tx.getAccountNumber())
                .param("customerCode", tx.getCustomerCode())
                .param("amount", tx.getAmount())
                .param("transactionType", tx.getTransactionType().name())
                .param("paymentMethod", tx.getPaymentMethod().name())
                .param("collectedBy", tx.getCollectedBy())
                .param("idempotencyKey", tx.getIdempotencyKey())
                .param("collectedTime", Timestamp.valueOf(tx.getCollectedTime()))
                .param("status", tx.getStatus().name())
                .param("createdTime", Timestamp.valueOf(tx.getCreatedTime()))
                .update();
    }

    @Override
    public Optional<SavingTransaction> findTransactionByIdempotencyKey(String idempotencyKey) {
        String sql = """
            SELECT Transaction_ID, Account_Number, Customer_Code, Amount,
                   Transaction_Type, Payment_Method, Collected_By, Idempotency_Key,
                   Collected_Time, Status, Created_Time
            FROM dbo.SYS_SAVING_TRANSACTION
            WHERE Idempotency_Key = :idempotencyKey
            """;

        return jdbcClient.sql(sql)
                .param("idempotencyKey", idempotencyKey)
                .query((rs, rowNum) -> SavingTransaction.builder()
                        .transactionId(rs.getString("Transaction_ID"))
                        .accountNumber(rs.getString("Account_Number"))
                        .customerCode(rs.getString("Customer_Code"))
                        .amount(rs.getBigDecimal("Amount"))
                        .transactionType(SavingTransactionType.valueOf(rs.getString("Transaction_Type")))
                        .paymentMethod(RepaymentMethod.valueOf(rs.getString("Payment_Method")))
                        .collectedBy(rs.getString("Collected_By"))
                        .idempotencyKey(rs.getString("Idempotency_Key"))
                        .collectedTime(rs.getTimestamp("Collected_Time").toLocalDateTime())
                        .status(RepaymentStatus.valueOf(rs.getString("Status")))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .build())
                .optional();
    }

    @Override
    public List<SavingTransaction> findTransactionsByAccountNumber(String accountNumber) {
        String sql = """
            SELECT Transaction_ID, Account_Number, Customer_Code, Amount,
                   Transaction_Type, Payment_Method, Collected_By, Idempotency_Key,
                   Collected_Time, Status, Created_Time
            FROM dbo.SYS_SAVING_TRANSACTION
            WHERE Account_Number = :accountNumber
            ORDER BY Collected_Time DESC
            """;

        return jdbcClient.sql(sql)
                .param("accountNumber", accountNumber)
                .query((rs, rowNum) -> SavingTransaction.builder()
                        .transactionId(rs.getString("Transaction_ID"))
                        .accountNumber(rs.getString("Account_Number"))
                        .customerCode(rs.getString("Customer_Code"))
                        .amount(rs.getBigDecimal("Amount"))
                        .transactionType(SavingTransactionType.valueOf(rs.getString("Transaction_Type")))
                        .paymentMethod(RepaymentMethod.valueOf(rs.getString("Payment_Method")))
                        .collectedBy(rs.getString("Collected_By"))
                        .idempotencyKey(rs.getString("Idempotency_Key"))
                        .collectedTime(rs.getTimestamp("Collected_Time").toLocalDateTime())
                        .status(RepaymentStatus.valueOf(rs.getString("Status")))
                        .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                        .build())
                .list();
    }
}
