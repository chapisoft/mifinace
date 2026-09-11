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
 * Phản hồi danh sách hợp đồng vay vốn và tiến độ trả nợ của Khách hàng thành viên.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Thông tin tổng hợp hợp đồng vay vốn của Khách hàng")
public class CustomerLoanSummaryResponse {

    @Schema(description = "Mã khách hàng", example = "CUST-99001")
    private String customerCode;

    @Schema(description = "Họ và tên khách hàng", example = "Daw Khin Myint")
    private String fullName;

    @Schema(description = "Mã Cụm/Tổ", example = "GRP-YGN-01")
    private String groupCode;

    @Schema(description = "Tổng dư nợ gốc hiện tại (MMK)", example = "450000.00")
    private BigDecimal totalOutstandingPrincipal;

    @Schema(description = "Tổng số kỳ đã thanh toán", example = "2")
    private int totalPeriodsPaid;

    @Schema(description = "Tổng số kỳ còn lại", example = "10")
    private int totalPeriodsRemaining;

    @Schema(description = "Danh sách chi tiết các kỳ nợ")
    private List<GroupScheduleRecord> schedules;
}
