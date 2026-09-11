package com.bmf.mobile.app.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Yêu cầu đồng bộ lịch thu nợ Cụm/Tổ của Cán bộ tín dụng (Offline Schedule Sync).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu tải và đồng bộ lịch thu nợ theo Cụm/Tổ")
public class SyncScheduleRequest {

    @NotBlank(message = "{validation.loan.groupCode.notBlank}")
    @Size(max = 32, message = "{validation.loan.groupCode.size}")
    @Schema(description = "Mã Cụm/Tổ", example = "GRP-YGN-01")
    private String groupCode;

    @Schema(description = "Ngày thu nợ kỳ này (định dạng YYYY-MM-DD), nếu để trống lấy ngày hiện tại", example = "2026-09-15")
    private String dueDate;
}
