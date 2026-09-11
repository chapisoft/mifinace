package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.SyncScheduleRequest;
import com.bmf.mobile.app.dto.response.ScheduleSyncResponse;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.repository.LoanRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SyncRepaymentScheduleUseCaseTest {

    @Mock
    private LoanRepository loanRepository;

    @InjectMocks
    private SyncRepaymentScheduleUseCase syncRepaymentScheduleUseCase;

    private GroupScheduleRecord record1;
    private GroupScheduleRecord record2;

    @BeforeEach
    void setUp() {
        record1 = GroupScheduleRecord.builder()
                .contractCode("HD-2026-001")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .groupCode("GRP-YGN-01")
                .periodNumber(1)
                .principalAmount(new BigDecimal("50000.00"))
                .interestAmount(new BigDecimal("6250.00"))
                .totalAmount(new BigDecimal("56250.00"))
                .dueDate(LocalDate.parse("2026-09-15"))
                .status("PENDING")
                .build();

        record2 = GroupScheduleRecord.builder()
                .contractCode("HD-2026-002")
                .customerCode("CUST-002")
                .customerName("U Kyaw Swar")
                .groupCode("GRP-YGN-01")
                .periodNumber(1)
                .principalAmount(new BigDecimal("60000.00"))
                .interestAmount(new BigDecimal("7500.00"))
                .totalAmount(new BigDecimal("67500.00"))
                .dueDate(LocalDate.parse("2026-09-15"))
                .status("PENDING")
                .build();
    }

    @Test
    @DisplayName("Đồng bộ lịch thu nợ Cụm/Tổ thành công - Tính toán đúng tổng số tiền và thành viên")
    void syncScheduleSuccessShouldReturnAggregatedSchedule() {
        SyncScheduleRequest request = SyncScheduleRequest.builder()
                .groupCode("GRP-YGN-01")
                .dueDate("2026-09-15")
                .build();

        when(loanRepository.findSchedulesByGroupCodeAndDate(eq("GRP-YGN-01"), eq(LocalDate.parse("2026-09-15"))))
                .thenReturn(List.of(record1, record2));

        ScheduleSyncResponse response = syncRepaymentScheduleUseCase.syncSchedule(request);

        assertNotNull(response);
        assertEquals("GRP-YGN-01", response.getGroupCode());
        assertEquals("2026-09-15", response.getDueDate());
        assertEquals(2, response.getTotalMembers());
        assertEquals(new BigDecimal("123750.00"), response.getTotalExpectedAmount());
        assertEquals(2, response.getSchedules().size());
    }
}
