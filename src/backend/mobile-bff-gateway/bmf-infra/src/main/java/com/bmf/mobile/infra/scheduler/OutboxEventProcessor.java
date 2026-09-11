package com.bmf.mobile.infra.scheduler;

import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.RepaymentTransaction;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.repository.LoanRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.bmf.mobile.domain.repository.RepaymentRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Tiến trình xử lý sự kiện Outbox Pattern chạy định kỳ trên Java 21 Virtual Threads.
 * Quét các sự kiện PENDING và đồng bộ quyết toán giao dịch vào CSDL Core NG-mFINA.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OutboxEventProcessor {

    private final OutboxEventRepository outboxEventRepository;
    private final LoanRepository loanRepository;
    private final RepaymentRepository repaymentRepository;
    private final ObjectMapper objectMapper;

    private static final int BATCH_SIZE = 50;

    @Scheduled(fixedDelayString = "${scheduler.outbox.delay-ms:5000}")
    public void processPendingEvents() {
        List<OutboxEvent> pendingEvents = outboxEventRepository.findPendingEvents(BATCH_SIZE);
        if (pendingEvents.isEmpty()) {
            return;
        }

        log.info("Outbox processor fetched {} pending events", pendingEvents.size());

        for (OutboxEvent event : pendingEvents) {
            try {
                processSingleEvent(event);
                outboxEventRepository.updateStatus(event.getEventId(), OutboxStatus.PROCESSED, null);
                log.info("Outbox event successfully processed: eventId={}, type={}",
                        event.getEventId(), event.getEventType());
            } catch (Exception e) {
                log.error("Failed to process Outbox event: eventId={}, retry={}",
                        event.getEventId(), event.getRetryCount() + 1, e);
                outboxEventRepository.updateStatus(event.getEventId(), OutboxStatus.FAILED, e.getMessage());
            }
        }
    }

    private void processSingleEvent(OutboxEvent event) throws Exception {
        if ("REPAYMENT_COLLECTED".equalsIgnoreCase(event.getEventType())) {
            RepaymentTransaction tx = objectMapper.readValue(event.getPayloadJson(), RepaymentTransaction.class);

            // 1. Cập nhật quyết toán vào bảng TD_LICH_THUNO trong Core Banking
            loanRepository.updateScheduleStatus(
                    tx.getContractCode(), tx.getPeriodNumber(), "SETTLED", tx.getTotalAmount());

            // 2. Cập nhật trạng thái giao dịch thu nợ sang SETTLED
            tx.setStatus(RepaymentStatus.SETTLED);
            repaymentRepository.save(tx);

            log.info("Settled loan repayment into Core NG-mFINA: contract={}, period={}, amount={}",
                    tx.getContractCode(), tx.getPeriodNumber(), tx.getTotalAmount());
        }
    }
}
