package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.WebhookPaymentRequest;
import com.bmf.mobile.app.dto.response.WebhookPaymentResponse;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.PaymentOrder;
import com.bmf.mobile.domain.entity.PaymentWebhookLog;
import com.bmf.mobile.domain.entity.RepaymentTransaction;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.enums.PaymentOrderStatus;
import com.bmf.mobile.domain.enums.PaymentProvider;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.DistributedLockPort;
import com.bmf.mobile.domain.repository.LoanRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.bmf.mobile.domain.repository.PaymentOrderRepository;
import com.bmf.mobile.domain.repository.PaymentWebhookLogRepository;
import com.bmf.mobile.domain.repository.RepaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * UseCase tiếp nhận Webhook gạch nợ tự động thời gian thực từ các ví điện tử Myanmar (KBZPay, WavePay, AYA Pay, MytelPay).
 * Bảo đảm tính nguyên tử và chống gạch nợ trùng qua Distributed Lock và Idempotency.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProcessWebhookPaymentUseCase {

    private final PaymentOrderRepository paymentOrderRepository;
    private final PaymentWebhookLogRepository webhookLogRepository;
    private final RepaymentRepository repaymentRepository;
    private final LoanRepository loanRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final DistributedLockPort distributedLockPort;

    public WebhookPaymentResponse processWebhook(PaymentProvider provider, WebhookPaymentRequest request, String traceId) {
        log.info("Processing webhook payment: provider={}, orderNo={}, partnerRefNo={}, amount={}, traceId={}",
                provider, request.getOrderNo(), request.getPartnerRefNo(), request.getAmount(), traceId);

        // 1. Tìm đơn hàng thanh toán
        PaymentOrder order = paymentOrderRepository.findByOrderNo(request.getOrderNo())
                .orElseThrow(() -> {
                    log.warn("Payment order not found for webhook: orderNo={}", request.getOrderNo());
                    saveWebhookLog(provider, request, "FAILED", "Order not found", traceId);
                    return new BusinessException(ErrorCode.ERR_PAYMENT_ORDER_NOT_FOUND);
                });

        // 2. Kiểm tra nếu đơn hàng đã được gạch nợ trước đó (Idempotent response)
        if (order.getStatus() == PaymentOrderStatus.SETTLED) {
            log.info("Payment order already settled (Idempotency): orderNo={}, settledTime={}",
                    order.getOrderNo(), order.getSettledTime());
            saveWebhookLog(provider, request, "SUCCESS_IDEMPOTENT", "Already settled", traceId);
            return WebhookPaymentResponse.builder()
                    .code("0")
                    .message("SUCCESS")
                    .orderNo(order.getOrderNo())
                    .partnerRefNo(order.getPartnerRefNo())
                    .settledTime(order.getSettledTime())
                    .build();
        }

        // 3. Kiểm tra hạn thanh toán
        if (LocalDateTime.now().isAfter(order.getExpiredTime())) {
            log.warn("Payment order expired: orderNo={}, expiredTime={}", order.getOrderNo(), order.getExpiredTime());
            paymentOrderRepository.updateStatus(order.getOrderNo(), PaymentOrderStatus.EXPIRED, request.getPartnerRefNo(), null);
            saveWebhookLog(provider, request, "EXPIRED", "Order expired", traceId);
            throw new BusinessException(ErrorCode.ERR_PAYMENT_ORDER_EXPIRED);
        }

        // 4. Chiếm Khóa phân tán Redisson trên mã khế ước vay và thực thi logic gạch nợ
        String lockKey = "LOAN_REPAYMENT:" + order.getLoanCode();

        return distributedLockPort.executeWithLock(lockKey, 5, 30, java.util.concurrent.TimeUnit.SECONDS, () -> {
            // Kiểm tra lại sau khi có khóa (Double Check)
            PaymentOrder lockedOrder = paymentOrderRepository.findByOrderNo(request.getOrderNo()).orElse(order);
            if (lockedOrder.getStatus() == PaymentOrderStatus.SETTLED) {
                return WebhookPaymentResponse.builder()
                        .code("0")
                        .message("SUCCESS")
                        .orderNo(lockedOrder.getOrderNo())
                        .partnerRefNo(lockedOrder.getPartnerRefNo())
                        .settledTime(lockedOrder.getSettledTime())
                        .build();
            }

            LocalDateTime now = LocalDateTime.now();
            String transactionId = "TX-DIGITAL-" + UUID.randomUUID();

            // 5. Ghi nhận giao dịch gạch nợ vào bảng SYS_REPAYMENT_TRANSACTION
            RepaymentTransaction tx = RepaymentTransaction.builder()
                    .transactionId(transactionId)
                    .contractCode(order.getLoanCode())
                    .customerCode("CUST-" + order.getLoanCode())
                    .customerName("MEMBER")
                    .groupCode("ONLINE")
                    .periodNumber(order.getScheduleId().intValue())
                    .principalAmount(request.getAmount())
                    .interestAmount(java.math.BigDecimal.ZERO)
                    .insuranceFee(java.math.BigDecimal.ZERO)
                    .compulsorySaving(java.math.BigDecimal.ZERO)
                    .penaltyAmount(java.math.BigDecimal.ZERO)
                    .totalAmount(request.getAmount())
                    .paymentMethod(RepaymentMethod.MMQR)
                    .idempotencyKey(request.getPartnerRefNo())
                    .collectedBy("DIGITAL_WALLET_" + provider.name())
                    .collectedTime(now)
                    .syncedTime(now)
                    .status(RepaymentStatus.SETTLED)
                    .notes("Settled via " + provider.name() + ", Ref=" + request.getPartnerRefNo())
                    .build();

            repaymentRepository.save(tx);

            // 6. Cập nhật trạng thái kỳ nợ trên CSDL Core
            loanRepository.updateScheduleStatus(order.getLoanCode(), order.getScheduleId().intValue(), "SETTLED", request.getAmount());

            // 7. Cập nhật trạng thái đơn hàng thanh toán sang SETTLED
            paymentOrderRepository.updateStatus(order.getOrderNo(), PaymentOrderStatus.SETTLED, request.getPartnerRefNo(), now);

            // 8. Đẩy sự kiện Outbox để bắn thông báo biến động số dư cho khách hàng qua FCM
            OutboxEvent outboxEvent = OutboxEvent.builder()
                    .aggregateType("LOAN_REPAYMENT")
                    .aggregateId(order.getLoanCode())
                    .eventType("PAYMENT_RECEIVED")
                    .payloadJson(String.format("{\"orderNo\":\"%s\",\"loanCode\":\"%s\",\"amount\":%s,\"provider\":\"%s\",\"partnerRefNo\":\"%s\"}",
                            order.getOrderNo(), order.getLoanCode(), request.getAmount(), provider.name(), request.getPartnerRefNo()))
                    .status(OutboxStatus.PENDING)
                    .retryCount(0)
                    .createdTime(now)
                    .build();

            outboxEventRepository.save(outboxEvent);

            log.info("Webhook payment settled successfully: orderNo={}, provider={}, partnerRefNo={}, txId={}",
                    order.getOrderNo(), provider, request.getPartnerRefNo(), transactionId);

            saveWebhookLog(provider, request, "SUCCESS", "Settled successfully, txId=" + transactionId, traceId);

            return WebhookPaymentResponse.builder()
                    .code("0")
                    .message("SUCCESS")
                    .orderNo(order.getOrderNo())
                    .partnerRefNo(request.getPartnerRefNo())
                    .settledTime(now)
                    .build();
        });
    }

    private void saveWebhookLog(PaymentProvider provider, WebhookPaymentRequest request, String status, String responsePayload, String traceId) {
        try {
            PaymentWebhookLog webhookLog = PaymentWebhookLog.builder()
                    .provider(provider)
                    .orderNo(request.getOrderNo())
                    .requestPayload(String.format("partnerRefNo=%s, amount=%s, timestamp=%s",
                            request.getPartnerRefNo(), request.getAmount(), request.getTimestamp()))
                    .responsePayload(responsePayload)
                    .signature(request.getSignature())
                    .status(status)
                    .traceId(traceId != null ? traceId : UUID.randomUUID().toString())
                    .createdTime(LocalDateTime.now())
                    .build();
            webhookLogRepository.save(webhookLog);
        } catch (Exception e) {
            log.error("Failed to persist webhook log: error={}", e.getMessage());
        }
    }
}
