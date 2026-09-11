package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.SyncScheduleRequest;
import com.bmf.mobile.app.dto.response.ScheduleSyncResponse;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.repository.LoanRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * UseCase xử lý đồng bộ danh mục lịch thu nợ Cụm/Tổ phục vụ Offline-first Mobile App.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SyncRepaymentScheduleUseCase {

    private final LoanRepository loanRepository;

    public ScheduleSyncResponse syncSchedule(SyncScheduleRequest request) {
        LocalDate dueDate = request.getDueDate() != null && !request.getDueDate().isBlank()
                ? LocalDate.parse(request.getDueDate())
                : LocalDate.now();

        log.info("Processing schedule sync: groupCode={}, dueDate={}", request.getGroupCode(), dueDate);

        List<GroupScheduleRecord> schedules = loanRepository.findSchedulesByGroupCodeAndDate(
                request.getGroupCode(), dueDate);

        BigDecimal totalExpectedAmount = schedules.stream()
                .map(s -> s.getTotalAmount() != null ? s.getTotalAmount() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int totalMembers = (int) schedules.stream()
                .map(GroupScheduleRecord::getCustomerCode)
                .distinct()
                .count();

        log.info("Schedule sync completed: groupCode={}, totalSchedules={}, totalMembers={}, totalAmount={}",
                request.getGroupCode(), schedules.size(), totalMembers, totalExpectedAmount);

        return ScheduleSyncResponse.builder()
                .groupCode(request.getGroupCode())
                .dueDate(dueDate.toString())
                .totalMembers(totalMembers)
                .totalExpectedAmount(totalExpectedAmount)
                .schedules(schedules)
                .serverTime(System.currentTimeMillis())
                .build();
    }
}
