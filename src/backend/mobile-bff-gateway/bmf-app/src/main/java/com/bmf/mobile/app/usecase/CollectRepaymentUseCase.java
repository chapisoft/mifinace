package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CollectRepaymentRequest;
import com.bmf.mobile.app.dto.response.RepaymentReceiptResponse;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.RepaymentTransaction;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.DistributedLockPort;
import com.bmf.mobile.domain.repository.LoanRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.bmf.mobile.domain.repository.RepaymentRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * UseCase xử lý gạch nợ tín dụng vi mô trực tuyến và ngoại tuyến có Distributed Lock và Outbox Pattern.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CollectRepaymentUseCase {

    private final RepaymentRepository repaymentRepository;
    private final LoanRepository loanRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final DistributedLockPort distributedLockPort;
    private final ObjectMapper objectMapper;

    private static final String LOCK_PREFIX = "BMF:LOCK:REPAYMENT:";
    private static final long LOCK_WAIT_SECONDS = 5;
    private static final long LOCK_LEASE_SECONDS = 10;

    @Transactional
    public RepaymentReceiptResponse collect(CollectRepaymentRequest request, String collectedByUserId) {
        log.info("Processing loan repayment collection: contract={}, customer={}, period={}, amount={}, idempotencyKey={}",
                request.getContractCode(), request.getCustomerCode(), request.getPeriodNumber(),
                request.getTotalAmount(), request.getIdempotencyKey());

        // 1. Kiểm tra Idempotency chống xử lý lặp giao dịch
        Optional<RepaymentTransaction> existingTx = repaymentRepository.findByIdempotencyKey(request.getIdempotencyKey());
        if (existingTx.isPresent()) {
            RepaymentTransaction tx = existingTx.get();
            log.info("Duplicate repayment request detected (Idempotent replay): txId={}, idempotencyKey={}",
                    tx.getTransactionId(), tx.getIdempotencyKey());
            return buildReceiptResponse(tx, BigDecimal.ZERO);
        }

        // 2. Bảo vệ tranh chấp dữ liệu đồng thời bằng Distributed Lock trên Redis
        String lockKey = LOCK_PREFIX + request.getContractCode() + ":" + request.getPeriodNumber();

        return distributedLockPort.executeWithLock(lockKey, LOCK_WAIT_SECONDS, LOCK_LEASE_SECONDS, TimeUnit.SECONDS, () -> {
            // Kiểm tra lại sau khi lấy khóa
            Optional<RepaymentTransaction> recheckTx = repaymentRepository.findByIdempotencyKey(request.getIdempotencyKey());
            if (recheckTx.isPresent()) {
                return buildReceiptResponse(recheckTx.get(), BigDecimal.ZERO);
            }

            // Tra cứu lịch nợ trong CSDL
            Optional<GroupScheduleRecord> scheduleOpt = loanRepository.findScheduleByContractAndPeriod(
                    request.getContractCode(), request.getPeriodNumber());

            if (scheduleOpt.isEmpty()) {
                log.warn("Repayment rejected - loan schedule not found: contract={}, period={}",
                        request.getContractCode(), request.getPeriodNumber());
                throw new BusinessException(ErrorCode.ERR_LOAN_NOT_FOUND);
            }

            GroupScheduleRecord schedule = scheduleOpt.get();
            if ("SETTLED".equalsIgnoreCase(schedule.getStatus()) || "COLLECTED".equalsIgnoreCase(schedule.getStatus())) {
                log.warn("Repayment rejected - schedule already settled: contract={}, period={}, currentStatus={}",
                        request.getContractCode(), request.getPeriodNumber(), schedule.getStatus());
                throw new BusinessException(ErrorCode.ERR_TRANSACTION_ALREADY_SETTLED);
            }

            String transactionId = "TX-" + UUID.randomUUID().toString().substring(0, 18).toUpperCase();
            LocalDateTime collectedTime = request.getOfflineTimestamp() != null && !request.getOfflineTimestamp().isBlank()
                    ? LocalDateTime.parse(request.getOfflineTimestamp())
                    : LocalDateTime.now();

            // 3. Khởi tạo và lưu thực thể RepaymentTransaction
            RepaymentTransaction transaction = RepaymentTransaction.builder()
                    .transactionId(transactionId)
                    .contractCode(request.getContractCode())
                    .customerCode(request.getCustomerCode())
                    .customerName(schedule.getCustomerName())
                    .groupCode(schedule.getGroupCode())
                    .periodNumber(request.getPeriodNumber())
                    .principalAmount(request.getPrincipalAmount())
                    .interestAmount(request.getInterestAmount())
                    .insuranceFee(request.getInsuranceFee())
                    .compulsorySaving(request.getCompulsorySaving())
                    .penaltyAmount(request.getPenaltyAmount())
                    .totalAmount(request.getTotalAmount())
                    .paymentMethod(request.getPaymentMethod())
                    .idempotencyKey(request.getIdempotencyKey())
                    .collectedBy(collectedByUserId)
                    .collectedTime(collectedTime)
                    .syncedTime(LocalDateTime.now())
                    .status(RepaymentStatus.COLLECTED)
                    .notes(request.getNotes())
                    .build();

            repaymentRepository.save(transaction);

            // 4. Sinh sự kiện Outbox Pattern vào bảng SYS_OUTBOX_EVENT
            try {
                String payloadJson = objectMapper.writeValueAsString(transaction);
                OutboxEvent outboxEvent = OutboxEvent.builder()
                        .aggregateType("LOAN")
                        .aggregateId(request.getContractCode())
                        .eventType("REPAYMENT_COLLECTED")
                        .payloadJson(payloadJson)
                        .status(OutboxStatus.PENDING)
                        .retryCount(0)
                        .maxRetries(5)
                        .createdTime(LocalDateTime.now())
                        .build();

                outboxEventRepository.save(outboxEvent);
            } catch (JsonProcessingException e) {
                log.error("Failed to serialize repayment payload for Outbox Event: txId={}", transactionId, e);
                throw new BusinessException(ErrorCode.ERR_INTERNAL_SERVER);
            }

            // 5. Cập nhật trạng thái kỳ nợ
            loanRepository.updateScheduleStatus(
                    request.getContractCode(), request.getPeriodNumber(), "COLLECTED", request.getTotalAmount());

            log.info("Repayment successfully recorded: txId={}, contract={}, period={}, amount={}",
                    transactionId, request.getContractCode(), request.getPeriodNumber(), request.getTotalAmount());

            return buildReceiptResponse(transaction, BigDecimal.ZERO);
        });
    }

    private RepaymentReceiptResponse buildReceiptResponse(RepaymentTransaction tx, BigDecimal remainingPrincipal) {
        return RepaymentReceiptResponse.builder()
                .transactionId(tx.getTransactionId())
                .contractCode(tx.getContractCode())
                .customerCode(tx.getCustomerCode())
                .customerName(tx.getCustomerName())
                .periodNumber(tx.getPeriodNumber())
                .paidAmount(tx.getTotalAmount())
                .remainingPrincipal(remainingPrincipal)
                .paymentMethod(tx.getPaymentMethod())
                .status(tx.getStatus())
                .transactionTime(tx.getCollectedTime() != null ? tx.getCollectedTime().toString() : LocalDateTime.now().toString())
                .collectedBy(tx.getCollectedBy())
                .idempotencyKey(tx.getIdempotencyKey())
                .build();
    }
}
