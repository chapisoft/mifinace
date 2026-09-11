package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.SavingAccount;
import com.bmf.mobile.domain.entity.SavingTransaction;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp dữ liệu tiết kiệm (Domain Repository Port).
 */
public interface SavingRepository {
    void saveAccount(SavingAccount account);
    Optional<SavingAccount> findAccountByNumber(String accountNumber);
    List<SavingAccount> findAccountsByCustomerCode(String customerCode);
    void updateAccountBalance(String accountNumber, BigDecimal newBalance);

    void saveTransaction(SavingTransaction transaction);
    Optional<SavingTransaction> findTransactionByIdempotencyKey(String idempotencyKey);
    List<SavingTransaction> findTransactionsByAccountNumber(String accountNumber);
}
