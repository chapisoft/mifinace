package com.bmf.mobile.app.worker;

import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.PushNotificationMessage;
import com.bmf.mobile.domain.enums.OutboxEventType;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.port.PushNotificationPort;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Worker xử lý hàng đợi sự kiện Outbox (SYS_OUTBOX_EVENT) trên Java 21 Virtual Threads.
 * Quét các sự kiện PENDING, định dạng thông báo đa ngôn ngữ (Myanmar Unicode Pyidaungsu & English),
 * và phân phối hàng loạt qua Firebase FCM HTTP/2.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationOutboxWorker {

    private final OutboxEventRepository outboxEventRepository;
    private final MobileDeviceRepository mobileDeviceRepository;
    private final PushNotificationPort pushNotificationPort;
    private final ObjectMapper objectMapper;

    private static final int BATCH_SIZE = 50;
    private static final DecimalFormat AMOUNT_FORMAT = new DecimalFormat("#,###");

    @Scheduled(fixedDelayString = "${scheduler.outbox.worker-delay-ms:1000}")
    public void processOutboxEvents() {
        List<OutboxEvent> pendingEvents = outboxEventRepository.findPendingEvents(BATCH_SIZE);
        if (pendingEvents == null || pendingEvents.isEmpty()) {
            return;
        }

        log.info("NotificationOutboxWorker fetched {} pending events for processing", pendingEvents.size());

        List<PushNotificationMessage> batchMessages = new ArrayList<>();
        Map<Long, OutboxEvent> eventMap = new HashMap<>();

        for (OutboxEvent event : pendingEvents) {
            try {
                eventMap.put(event.getEventId(), event);
                List<PushNotificationMessage> msgs = convertEventToPushMessages(event);
                batchMessages.addAll(msgs);
            } catch (Exception e) {
                log.error("Failed to parse Outbox event: eventId={}, error={}", event.getEventId(), e.getMessage(), e);
                outboxEventRepository.updateStatus(event.getEventId(), OutboxStatus.FAILED, e.getMessage());
            }
        }

        if (!batchMessages.isEmpty()) {
            int sentCount = pushNotificationPort.sendBatchNotifications(batchMessages);
            log.info("Batch push notification completed: dispatched {} messages out of {}", sentCount, batchMessages.size());
        }

        // Cập nhật trạng thái sự kiện Outbox sang SENT
        for (OutboxEvent event : pendingEvents) {
            try {
                outboxEventRepository.updateStatus(event.getEventId(), OutboxStatus.SENT, null);
                log.info("Marked Outbox event as SENT: eventId={}, eventType={}", event.getEventId(), event.getEventType());
            } catch (Exception e) {
                log.error("Failed to update status for Outbox event: eventId={}", event.getEventId(), e);
            }
        }
    }

    private List<PushNotificationMessage> convertEventToPushMessages(OutboxEvent event) throws Exception {
        List<PushNotificationMessage> messages = new ArrayList<>();
        JsonNode payload = objectMapper.readTree(event.getPayloadJson());

        String customerId = payload.has("customerId") ? payload.get("customerId").asText() : event.getAggregateId();
        List<MobileDevice> activeDevices = mobileDeviceRepository.findActiveDevicesByUserId(customerId, UserType.CUSTOMER);

        if (activeDevices.isEmpty()) {
            log.debug("No active customer devices registered for customerId={}", customerId);
            return messages;
        }

        NotificationContent content = formatNotificationContent(event.getEventType(), payload);
        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("eventId", String.valueOf(event.getEventId()));
        dataPayload.put("aggregateType", event.getAggregateType());
        dataPayload.put("aggregateId", event.getAggregateId());
        dataPayload.put("eventType", event.getEventType());

        for (MobileDevice device : activeDevices) {
            if (device.getPushToken() != null && !device.getPushToken().isBlank()) {
                messages.add(PushNotificationMessage.builder()
                        .targetPushToken(device.getPushToken())
                        .targetUserId(customerId)
                        .title(content.title())
                        .body(content.body())
                        .dataPayload(dataPayload)
                        .channelId("bmf_finance_notifications")
                        .build());
            }
        }

        return messages;
    }

    private NotificationContent formatNotificationContent(String eventType, JsonNode payload) {
        String amountStr = "";
        if (payload.has("amount")) {
            BigDecimal amt = new BigDecimal(payload.get("amount").asText());
            amountStr = AMOUNT_FORMAT.format(amt) + " MMK";
        }

        if (OutboxEventType.LOAN_DISBURSED.name().equalsIgnoreCase(eventType)) {
            String contractCode = payload.has("contractCode") ? payload.get("contractCode").asText() : "";
            String title = "ချေးငွေထုတ်ပေးခြင်း အောင်မြင်ပါသည် / Loan Disbursed";
            String body = String.format("စာချုပ်အမှတ် %s အတွက် ကျပ် %s အောင်မြင်စွာ ထုတ်ပေးပြီးပါပြီ။ / Loan %s disbursed successfully: %s",
                    contractCode, amountStr, contractCode, amountStr);
            return new NotificationContent(title, body);
        }

        if (OutboxEventType.PAYMENT_RECEIVED.name().equalsIgnoreCase(eventType)
                || OutboxEventType.REPAYMENT_COLLECTED.name().equalsIgnoreCase(eventType)) {
            String period = payload.has("periodNumber") ? payload.get("periodNumber").asText() : "1";
            String title = "ချေးငွေအရစ်ကျ လက်ခံရရှိပါသည် / Repayment Received";
            String body = String.format("အရစ်ကျအမှတ် (%s) အတွက် ကျပ် %s ပေးသွင်းမှု အောင်မြင်ပါသည်။ / Repayment for period %s received: %s",
                    period, amountStr, period, amountStr);
            return new NotificationContent(title, body);
        }

        if (OutboxEventType.SAVING_DEPOSITED.name().equalsIgnoreCase(eventType)) {
            String title = "စုဆောင်းငွေ ထည့်သွင်းခြင်း အောင်မြင်ပါသည် / Savings Deposited";
            String body = String.format("စုဆောင်းငွေ ကျပ် %s အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ။ / Savings deposit received: %s",
                    amountStr, amountStr);
            return new NotificationContent(title, body);
        }

        if (OutboxEventType.SAVING_WITHDRAWN.name().equalsIgnoreCase(eventType)) {
            String title = "စုဆောင်းငွေ ထုတ်ယူခြင်း အောင်မြင်ပါသည် / Savings Withdrawn";
            String body = String.format("စုဆောင်းငွေ ကျပ် %s အောင်မြင်စွာ ထုတ်ယူပြီးပါပြီ။ / Savings withdrawal completed: %s",
                    amountStr, amountStr);
            return new NotificationContent(title, body);
        }

        if (OutboxEventType.LOAN_DUE_REMINDER.name().equalsIgnoreCase(eventType)) {
            String dueDate = payload.has("dueDate") ? payload.get("dueDate").asText() : "";
            String title = "ချေးငွေပေးဆပ်ရန် သတိပေးချက် / Loan Payment Reminder";
            String body = String.format("ရက်စွဲ %s တွင် ကျပ် %s ပေးဆပ်ရန် ရှိပါသည် ကျေးဇူးပြု၍ ပြင်ဆင်ထားပါ။ / Due date %s: Amount %s is due for payment.",
                    dueDate, amountStr, dueDate, amountStr);
            return new NotificationContent(title, body);
        }

        // Mặc định
        return new NotificationContent("BMF Microfinance Notification", "New transaction update received: " + amountStr);
    }

    private record NotificationContent(String title, String body) {}
}
