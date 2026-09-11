package com.bmf.mobile.app.scheduler;

import com.bmf.mobile.app.usecase.LoanDueReminderUseCase;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Cron Job chạy quét nợ đến hạn 08:00 AM hàng ngày, được bảo vệ bằng ShedLock Redis.
 * Đảm bảo khi chạy cụm phân tán nhiều container/node, chỉ duy nhất 1 node chiếm khóa và thực thi.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LoanDueReminderJob {

    private final LoanDueReminderUseCase loanDueReminderUseCase;

    /**
     * Chạy định kỳ vào 08:00 AM mỗi ngày (giờ Myanmar UTC+06:30).
     * Khóa ShedLock: giữ tối thiểu 15 phút (lockAtLeastFor), tối đa 30 phút (lockAtMostFor).
     */
    @Scheduled(cron = "${scheduler.loan-due.cron:0 0 8 * * ?}")
    @SchedulerLock(name = "LoanDueReminderTask", lockAtLeastFor = "15m", lockAtMostFor = "30m")
    public void runDailyLoanDueReminder() {
        log.info("Starting Daily Loan Due Reminder Job at 08:00 AM Myanmar Time");
        try {
            int remindersCreated = loanDueReminderUseCase.scanAndGenerateDueReminders();
            log.info("Daily Loan Due Reminder Job completed successfully: created {} reminders", remindersCreated);
        } catch (Exception e) {
            log.error("Error occurred while executing Daily Loan Due Reminder Job: {}", e.getMessage(), e);
        }
    }
}
