package com.bmf.mobile.app.usecase;

import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.AggregateType;
import com.bmf.mobile.domain.enums.OutboxEventType;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.repository.LoanRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Use case quét và phát sinh sự kiện nhắc nợ tự động (Loan Due Reminder) cho các khoản vay sắp đến hạn.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LoanDueReminderUseCase {

    private final LoanRepository loanRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    /**
     * Quét các khoản nợ có ngày đến hạn trong khoảng [Hôm nay + 1, Hôm nay + 3] ngày tới,
     * và sinh bản ghi sự kiện LOAN_DUE_REMINDER vào bảng SYS_OUTBOX_EVENT.
     *
     * @return Số lượng bản ghi nhắc nợ đã được tạo
     */
    public int scanAndGenerateDueReminders() {
        LocalDate today = LocalDate.now();
        LocalDate fromDate = today.plusDays(1);
        LocalDate toDate = today.plusDays(3);

        log.info("Starting scan for due loans between {} and {}", fromDate, toDate);
        List<GroupScheduleRecord> dueSchedules = loanRepository.findSchedulesDueBetween(fromDate, toDate);

        if (dueSchedules == null || dueSchedules.isEmpty()) {
            log.info("No upcoming due loans found for reminder period [{} - {}]", fromDate, toDate);
            return 0;
        }

        int count = 0;
        for (GroupScheduleRecord schedule : dueSchedules) {
            try {
                Map<String, Object> payload = new HashMap<>();
                payload.put("contractCode", schedule.getContractCode());
                payload.put("customerId", schedule.getCustomerCode());
                payload.put("customerName", schedule.getCustomerName());
                payload.put("periodNumber", schedule.getPeriodNumber());
                payload.put("amount", schedule.getTotalAmount());
                payload.put("dueDate", schedule.getDueDate() != null ? schedule.getDueDate().toString() : "");
                payload.put("currency", "MMK");

                String payloadJson = objectMapper.writeValueAsString(payload);

                OutboxEvent event = OutboxEvent.builder()
                        .aggregateType(AggregateType.LOAN.name())
                        .aggregateId(schedule.getContractCode())
                        .eventType(OutboxEventType.LOAN_DUE_REMINDER.name())
                        .payloadJson(payloadJson)
                        .status(OutboxStatus.PENDING)
                        .retryCount(0)
                        .maxRetries(5)
                        .createdTime(LocalDateTime.now())
                        .build();

                outboxEventRepository.save(event);
                count++;
            } catch (Exception e) {
                log.error("Failed to generate due reminder for contract={}, period={}, error={}",
                        schedule.getContractCode(), schedule.getPeriodNumber(), e.getMessage(), e);
            }
        }

        log.info("Successfully generated {} loan due reminder events into SYS_OUTBOX_EVENT", count);
        return count;
    }
}
