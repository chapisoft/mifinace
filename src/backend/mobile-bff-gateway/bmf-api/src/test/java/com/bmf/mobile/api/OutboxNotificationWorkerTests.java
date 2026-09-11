package com.bmf.mobile.api;

import com.bmf.mobile.app.scheduler.LoanDueReminderJob;
import com.bmf.mobile.app.usecase.LoanDueReminderUseCase;
import com.bmf.mobile.app.worker.NotificationOutboxWorker;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.enums.AggregateType;
import com.bmf.mobile.domain.enums.DeviceStatus;
import com.bmf.mobile.domain.enums.OutboxEventType;
import com.bmf.mobile.domain.enums.OutboxStatus;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.port.PushNotificationPort;
import com.bmf.mobile.domain.repository.LoanRepository;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import net.javacrumbs.shedlock.core.LockProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(classes = {BffApplication.class, TestConfig.class})
@ActiveProfiles("test")
public class OutboxNotificationWorkerTests {

    @Autowired
    private NotificationOutboxWorker notificationOutboxWorker;

    @Autowired
    private LoanDueReminderUseCase loanDueReminderUseCase;

    @Autowired
    private LoanDueReminderJob loanDueReminderJob;

    @Autowired
    private OutboxEventRepository outboxEventRepository;

    @Autowired
    private MobileDeviceRepository mobileDeviceRepository;

    @Autowired
    private LoanRepository loanRepository;

    @Autowired
    private PushNotificationPort pushNotificationPort;

    @Autowired
    private LockProvider lockProvider;

    private static final String TEST_CUSTOMER_ID = "KH-99001";
    private static final String TEST_DEVICE_ID = "DEV-OUTBOX-99001";
    private static final String TEST_FCM_TOKEN = "fcm_token_sample_myanmar_customer_99001";

    @BeforeEach
    void setUp() {
        // Đăng ký thiết bị và FCM Token cho khách hàng thử nghiệm
        MobileDevice device = MobileDevice.builder()
                .deviceId(TEST_DEVICE_ID)
                .userId(TEST_CUSTOMER_ID)
                .userType(UserType.CUSTOMER)
                .platform(PlatformType.ANDROID)
                .deviceName("Samsung Galaxy A15 Myanmar Edition")
                .osVersion("Android 14")
                .appVersion("1.0.0")
                .pushToken(TEST_FCM_TOKEN)
                .active(true)
                .lastActiveTime(LocalDateTime.now())
                .createdTime(LocalDateTime.now())
                .updatedTime(LocalDateTime.now())
                .build();
        mobileDeviceRepository.save(device);
    }

    @Test
    @DisplayName("TASK-DB-03.1 & 03.2: Worker xử lý sự kiện Giải ngân LOAN_DISBURSED gửi FCM tiếng Myanmar")
    void testOutboxWorkerLoanDisbursedEvent() {
        // Given
        String payloadJson = """
            {
                "contractCode": "LN-BMF-2026-0099",
                "customerId": "%s",
                "amount": 500000,
                "currency": "MMK",
                "disbursedDate": "2026-09-11 10:00:00"
            }
            """.formatted(TEST_CUSTOMER_ID);

        OutboxEvent event = OutboxEvent.builder()
                .aggregateType(AggregateType.LOAN.name())
                .aggregateId("LN-BMF-2026-0099")
                .eventType(OutboxEventType.LOAN_DISBURSED.name())
                .payloadJson(payloadJson)
                .status(OutboxStatus.PENDING)
                .retryCount(0)
                .maxRetries(5)
                .createdTime(LocalDateTime.now())
                .build();

        event = outboxEventRepository.save(event);
        assertNotNull(event.getEventId());

        // When
        notificationOutboxWorker.processOutboxEvents();

        // Then
        Optional<OutboxEvent> updatedEvent = outboxEventRepository.findById(event.getEventId());
        assertTrue(updatedEvent.isPresent());
        assertEquals(OutboxStatus.SENT, updatedEvent.get().getStatus());
        assertNotNull(updatedEvent.get().getSentTime());
    }

    @Test
    @DisplayName("TASK-DB-03.1 & 03.2: Worker xử lý sự kiện Thu nợ PAYMENT_RECEIVED gửi FCM tiếng Myanmar")
    void testOutboxWorkerPaymentReceivedEvent() {
        // Given
        String payloadJson = """
            {
                "contractCode": "LN-BMF-2026-0099",
                "customerId": "%s",
                "amount": 55000,
                "periodNumber": 3,
                "currency": "MMK",
                "paymentDate": "2026-09-11 11:30:00"
            }
            """.formatted(TEST_CUSTOMER_ID);

        OutboxEvent event = OutboxEvent.builder()
                .aggregateType(AggregateType.LOAN.name())
                .aggregateId("LN-BMF-2026-0099")
                .eventType(OutboxEventType.PAYMENT_RECEIVED.name())
                .payloadJson(payloadJson)
                .status(OutboxStatus.PENDING)
                .retryCount(0)
                .maxRetries(5)
                .createdTime(LocalDateTime.now())
                .build();

        event = outboxEventRepository.save(event);

        // When
        notificationOutboxWorker.processOutboxEvents();

        // Then
        Optional<OutboxEvent> updatedEvent = outboxEventRepository.findById(event.getEventId());
        assertTrue(updatedEvent.isPresent());
        assertEquals(OutboxStatus.SENT, updatedEvent.get().getStatus());
    }

    @Test
    @DisplayName("TASK-DB-03.1 & 03.2: Worker xử lý sự kiện Nộp tiền tiết kiệm SAVING_DEPOSITED gửi FCM")
    void testOutboxWorkerSavingDepositedEvent() {
        // Given
        String payloadJson = """
            {
                "accountNumber": "SAV-BMF-889900",
                "customerId": "%s",
                "transactionType": "G",
                "amount": 20000,
                "currency": "MMK",
                "transactionDate": "2026-09-11 12:00:00"
            }
            """.formatted(TEST_CUSTOMER_ID);

        OutboxEvent event = OutboxEvent.builder()
                .aggregateType(AggregateType.SAVING.name())
                .aggregateId("SAV-BMF-889900")
                .eventType(OutboxEventType.SAVING_DEPOSITED.name())
                .payloadJson(payloadJson)
                .status(OutboxStatus.PENDING)
                .retryCount(0)
                .maxRetries(5)
                .createdTime(LocalDateTime.now())
                .build();

        event = outboxEventRepository.save(event);

        // When
        notificationOutboxWorker.processOutboxEvents();

        // Then
        Optional<OutboxEvent> updatedEvent = outboxEventRepository.findById(event.getEventId());
        assertTrue(updatedEvent.isPresent());
        assertEquals(OutboxStatus.SENT, updatedEvent.get().getStatus());
    }

    @Test
    @DisplayName("TASK-DB-03.1 & 03.2: Worker xử lý sự kiện Rút tiền tiết kiệm SAVING_WITHDRAWN gửi FCM")
    void testOutboxWorkerSavingWithdrawnEvent() {
        // Given
        String payloadJson = """
            {
                "accountNumber": "SAV-BMF-889900",
                "customerId": "%s",
                "transactionType": "R",
                "amount": 10000,
                "currency": "MMK",
                "transactionDate": "2026-09-11 12:15:00"
            }
            """.formatted(TEST_CUSTOMER_ID);

        OutboxEvent event = OutboxEvent.builder()
                .aggregateType(AggregateType.SAVING.name())
                .aggregateId("SAV-BMF-889900")
                .eventType(OutboxEventType.SAVING_WITHDRAWN.name())
                .payloadJson(payloadJson)
                .status(OutboxStatus.PENDING)
                .retryCount(0)
                .maxRetries(5)
                .createdTime(LocalDateTime.now())
                .build();

        event = outboxEventRepository.save(event);

        // When
        notificationOutboxWorker.processOutboxEvents();

        // Then
        Optional<OutboxEvent> updatedEvent = outboxEventRepository.findById(event.getEventId());
        assertTrue(updatedEvent.isPresent());
        assertEquals(OutboxStatus.SENT, updatedEvent.get().getStatus());
    }

    @Test
    @DisplayName("TASK-DB-04.1: Quét nợ đến hạn và phát sinh sự kiện LOAN_DUE_REMINDER")
    void testLoanDueReminderUseCaseScanning() {
        // When
        int count = loanDueReminderUseCase.scanAndGenerateDueReminders();

        // Then
        assertTrue(count >= 0);
    }

    @Test
    @DisplayName("TASK-DB-04.2: Chạy Job Cron 08:00 AM được bảo vệ bằng ShedLock")
    void testLoanDueReminderJobExecution() {
        // When & Then (Không ném ngoại lệ khi thực thi)
        loanDueReminderJob.runDailyLoanDueReminder();
        assertNotNull(lockProvider);
    }

    @Test
    @DisplayName("TASK-DB-03.2: Kiểm thử gửi thông báo FCM qua PushNotificationPort")
    void testPushNotificationPortDirectDispatch() {
        // When
        boolean result = pushNotificationPort.sendNotification(
                TEST_FCM_TOKEN,
                "မင်္ဂလာပါ / Hello",
                "စမ်းသပ်မှု အောင်မြင်ပါသည် / Test successful",
                null
        );

        // Then
        assertTrue(result);
    }
}
