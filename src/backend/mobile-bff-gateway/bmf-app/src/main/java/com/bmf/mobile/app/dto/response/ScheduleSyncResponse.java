package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

/**
 * Phản hồi danh mục lịch thu nợ Cụm/Tổ phục vụ lưu trữ Offline SQLite trên thiết bị di động.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Thông tin lịch thu nợ đồng bộ Cụm/Tổ")
public class ScheduleSyncResponse {

    @Schema(description = "Mã Cụm/Tổ", example = "GRP-YGN-01")
    private String groupCode;

    @Schema(description = "Ngày thu nợ", example = "2026-09-15")
    private String dueDate;

    @Schema(description = "Tổng số thành viên có lịch nợ đến hạn trong kỳ", example = "15")
    private int totalMembers;

    @Schema(description = "Tổng số tiền cần thu trong kỳ của Cụm/Tổ (MMK)", example = "888750.00")
    private BigDecimal totalExpectedAmount;

    @Schema(description = "Danh sách chi tiết lịch nợ của từng thành viên")
    private List<GroupScheduleRecord> schedules;

    @Schema(description = "Thời điểm hệ thống phản hồi đồng bộ (epoch millis)", example = "1789095455915")
    private long serverTime;
}
