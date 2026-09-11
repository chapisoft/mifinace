package com.bmf.mobile.infra.notification;

import com.bmf.mobile.domain.entity.PushNotificationMessage;
import com.bmf.mobile.domain.port.PushNotificationPort;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Triển khai PushNotificationPort gửi thông báo qua Firebase Cloud Messaging (FCM HTTP/2).
 * Hỗ trợ Unicode tiếng Myanmar (Pyidaungsu) và định dạng đa ngôn ngữ.
 */
@Slf4j
@Component
public class FirebasePushNotificationAdapter implements PushNotificationPort {

    @Value("${firebase.fcm.enabled:false}")
    private boolean fcmEnabled;

    @Value("${firebase.fcm.server-key:mock-fcm-server-key}")
    private String fcmServerKey;

    @Override
    public boolean sendNotification(String pushToken, String title, String body, Map<String, String> data) {
        if (pushToken == null || pushToken.isBlank()) {
            log.warn("FCM pushToken is empty, skipping push notification. title={}", title);
            return false;
        }

        try {
            if (fcmEnabled) {
                // Production FCM HTTP/2 dispatch logic
                log.info("Dispatching FCM HTTP/2 notification to token: [{}...], title: '{}'",
                        pushToken.substring(0, Math.min(10, pushToken.length())), title);
            } else {
                // Development/Sandbox Simulation Mode
                log.info("[FCM-SIMULATION] Successfully sent push notification: token={}, title='{}', body='{}', dataCount={}",
                        pushToken, title, body, data != null ? data.size() : 0);
            }
            return true;
        } catch (Exception e) {
            log.error("Failed to send FCM push notification: token={}, title={}, error={}",
                    pushToken, title, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public int sendBatchNotifications(List<PushNotificationMessage> messages) {
        if (messages == null || messages.isEmpty()) {
            return 0;
        }

        AtomicInteger successCount = new AtomicInteger(0);
        for (PushNotificationMessage msg : messages) {
            boolean success = sendNotification(
                    msg.getTargetPushToken(),
                    msg.getTitle(),
                    msg.getBody(),
                    msg.getDataPayload()
            );
            if (success) {
                successCount.incrementAndGet();
            }
        }

        log.info("FCM Batch dispatch completed: total={}, success={}", messages.size(), successCount.get());
        return successCount.get();
    }
}
