package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CollectSavingDepositRequest;
import com.bmf.mobile.app.dto.request.OpenSavingAccountRequest;
import com.bmf.mobile.app.dto.response.SavingAccountResponse;
import com.bmf.mobile.app.dto.response.SavingTransactionReceiptResponse;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.SavingAccount;
import com.bmf.mobile.domain.entity.SavingTransaction;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingTransactionType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.DistributedLockPort;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.bmf.mobile.domain.repository.SavingRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * UseCase quản lý toàn diện sổ tiết kiệm: Mở sổ, Nộp tiền gửi, và Tra cứu số dư lãi tích lũy.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ManageSavingsUseCase {

    private final SavingRepository savingRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final DistributedLockPort distributedLockPort;
    private final ObjectMapper objectMapper;

    @Transactional
    public SavingAccountResponse openAccount(OpenSavingAccountRequest request, String createdBy) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);
        String accountNumber = "SA-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        log.info("[{}] Opening saving account: number={}, custCode={}, productType={}, createdBy={}",
                traceId, accountNumber, request.getCustomerCode(), request.getProductType(), createdBy);

        BigDecimal defaultInterestRate = BigDecimal.valueOf(10.00); // 10% / năm chuẩn vi mô
        LocalDateTime now = LocalDateTime.now();

        SavingAccount account = SavingAccount.builder()
                .accountNumber(accountNumber)
                .customerCode(request.getCustomerCode())
                .customerName(request.getCustomerName())
                .productType(request.getProductType())
                .balance(request.getInitialDeposit())
                .interestRate(defaultInterestRate)
                .termMonths(request.getTermMonths() != null ? request.getTermMonths() : 0)
                .beneficiaryName(request.getBeneficiaryName())
                .beneficiaryNrc(request.getBeneficiaryNrc())
                .status(SavingAccountStatus.ACTIVE)
                .createdBy(createdBy)
                .createdTime(now)
                .build();

        savingRepository.saveAccount(account);

        // Nếu có tiền gửi ban đầu, ghi nhận giao dịch nạp đầu tiên
        if (request.getInitialDeposit().compareTo(BigDecimal.ZERO) > 0) {
            String initialTxId = "TX-SAV-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            SavingTransaction tx = SavingTransaction.builder()
                    .transactionId(initialTxId)
                    .accountNumber(accountNumber)
                    .customerCode(request.getCustomerCode())
                    .amount(request.getInitialDeposit())
                    .transactionType(SavingTransactionType.DEPOSIT)
                    .paymentMethod(com.bmf.mobile.domain.enums.RepaymentMethod.CASH)
                    .collectedBy(createdBy)
                    .idempotencyKey("INIT-" + accountNumber)
                    .collectedTime(now)
                    .status(RepaymentStatus.COLLECTED)
                    .createdTime(now)
                    .build();
            savingRepository.saveTransaction(tx);
        }

        return mapToAccountResponse(account);
    }

    public SavingTransactionReceiptResponse collectDeposit(CollectSavingDepositRequest request, String collectedBy) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);

        // 1. Bẫy Idempotency
        Optional<SavingTransaction> existingTx = savingRepository.findTransactionByIdempotencyKey(request.getIdempotencyKey());
        if (existingTx.isPresent()) {
            SavingTransaction tx = existingTx.get();
            log.info("[{}] Idempotent saving deposit request detected for key={}: returning existing receipt={}",
                    traceId, request.getIdempotencyKey(), tx.getTransactionId());
            return SavingTransactionReceiptResponse.builder()
                    .transactionId(tx.getTransactionId())
                    .accountNumber(tx.getAccountNumber())
                    .customerCode(tx.getCustomerCode())
                    .amount(tx.getAmount())
                    .newBalance(BigDecimal.ZERO) // Cached response
                    .transactionType(tx.getTransactionType())
                    .paymentMethod(tx.getPaymentMethod())
                    .status(tx.getStatus())
                    .transactionTime(tx.getCollectedTime())
                    .build();
        }

        // 2. Chiếm khóa phân tán trên sổ tiết kiệm
        String lockKey = "LOCK:SAVING_ACC:" + request.getAccountNumber();
        return distributedLockPort.executeWithLock(lockKey, 5, 10, TimeUnit.SECONDS, () -> {
            return processSavingDepositInternal(request, collectedBy);
        });
    }

    @Transactional
    protected SavingTransactionReceiptResponse processSavingDepositInternal(CollectSavingDepositRequest request, String collectedBy) {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);

        SavingAccount account = savingRepository.findAccountByNumber(request.getAccountNumber())
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_RESOURCE_NOT_FOUND, "Saving account not found"));

        if (account.getStatus() != SavingAccountStatus.ACTIVE) {
            log.warn("[{}] Cannot deposit to inactive saving account: number={}, status={}",
                    traceId, account.getAccountNumber(), account.getStatus());
            throw new BusinessException(ErrorCode.ERR_CONFLICT, "Saving account is not active");
        }

        BigDecimal newBalance = account.getBalance().add(request.getAmount());
        savingRepository.updateAccountBalance(account.getAccountNumber(), newBalance);

        String txId = "TX-SAV-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        LocalDateTime collectedTime = request.getOfflineTimestamp() != null
                ? LocalDateTime.parse(request.getOfflineTimestamp())
                : LocalDateTime.now();

        SavingTransaction transaction = SavingTransaction.builder()
                .transactionId(txId)
                .accountNumber(account.getAccountNumber())
                .customerCode(request.getCustomerCode())
                .amount(request.getAmount())
                .transactionType(SavingTransactionType.DEPOSIT)
                .paymentMethod(request.getPaymentMethod())
                .collectedBy(collectedBy)
                .idempotencyKey(request.getIdempotencyKey())
                .collectedTime(collectedTime)
                .status(RepaymentStatus.COLLECTED)
                .createdTime(LocalDateTime.now())
                .build();

        savingRepository.saveTransaction(transaction);

        // Sinh Outbox Event gửi thông báo biến động số dư
        try {
            String payloadJson = objectMapper.writeValueAsString(transaction);
            OutboxEvent event = OutboxEvent.builder()
                    .aggregateType("SAVING_ACCOUNT")
                    .aggregateId(account.getAccountNumber())
                    .eventType("SAVING_DEPOSITED")
                    .payloadJson(payloadJson)
                    .status(OutboxStatus.PENDING)
                    .retryCount(0)
                    .maxRetries(5)
                    .createdTime(LocalDateTime.now())
                    .build();
            outboxEventRepository.save(event);
        } catch (Exception ex) {
            log.error("[{}] Failed to serialize Outbox event for saving deposit: {}", traceId, txId, ex);
        }

        return SavingTransactionReceiptResponse.builder()
                .transactionId(txId)
                .accountNumber(account.getAccountNumber())
                .customerCode(account.getCustomerCode())
                .amount(request.getAmount())
                .newBalance(newBalance)
                .transactionType(SavingTransactionType.DEPOSIT)
                .paymentMethod(request.getPaymentMethod())
                .status(RepaymentStatus.COLLECTED)
                .transactionTime(collectedTime)
                .build();
    }

    public List<SavingAccountResponse> getMySavingAccounts(String customerCode) {
        List<SavingAccount> accounts = savingRepository.findAccountsByCustomerCode(customerCode);
        return accounts.stream()
                .map(this::mapToAccountResponse)
                .collect(Collectors.toList());
    }

    private SavingAccountResponse mapToAccountResponse(SavingAccount account) {
        // Ước tính lãi dồn tích: Số dư * Lãi suất * 30 ngày / 365
        BigDecimal accruedInterest = account.getBalance()
                .multiply(account.getInterestRate())
                .multiply(BigDecimal.valueOf(30))
                .divide(BigDecimal.valueOf(36500), 2, RoundingMode.HALF_UP);

        return SavingAccountResponse.builder()
                .accountNumber(account.getAccountNumber())
                .customerCode(account.getCustomerCode())
                .customerName(account.getCustomerName())
                .productType(account.getProductType())
                .balance(account.getBalance())
                .interestRate(account.getInterestRate())
                .accruedInterest(accruedInterest)
                .termMonths(account.getTermMonths())
                .status(account.getStatus())
                .createdTime(account.getCreatedTime())
                .build();
    }
}
