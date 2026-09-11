package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.LoanApplicationStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Phản hồi chi tiết hồ sơ vay vốn sau khi tiếp nhận và chấm điểm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Thông tin phản hồi kết quả tiếp nhận hồ sơ vay vốn")
public class LoanApplicationResponse {

    @Schema(description = "Mã định danh hồ sơ vay vốn", example = "APP-2026-0089")
    private String applicationId;

    @Schema(description = "Mã khách hàng", example = "CUST-001")
    private String customerCode;

    @Schema(description = "Họ và tên khách hàng", example = "Daw Khin Myint")
    private String customerName;

    @Schema(description = "Mã Cụm/Tổ", example = "GRP-YGN-01")
    private String groupCode;

    @Schema(description = "Số tiền đề nghị vay (MMK)", example = "500000.00")
    private BigDecimal requestedAmount;

    @Schema(description = "Kỳ hạn vay (tháng)", example = "12")
    private Integer termMonths;

    @Schema(description = "Trạng thái hồ sơ", example = "SUBMITTED")
    private LoanApplicationStatus status;

    @Schema(description = "Điểm tín dụng chấm sơ bộ (Credit Score)", example = "780")
    private Integer creditScore;

    @Schema(description = "Thời gian nộp hồ sơ", example = "2026-09-15T10:30:00")
    private LocalDateTime createdTime;
}
