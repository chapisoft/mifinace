package com.bmf.mobile.app.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Yêu cầu sinh mã QR bàn giao quỹ tiền mặt cuối ngày.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu sinh mã QR bàn giao quỹ tiền mặt lưu động")
public class GenerateCashHandoverQrRequest {

    @Schema(description = "Ngày bàn giao quỹ (YYYY-MM-DD), để trống nếu là hôm nay", example = "2026-09-15")
    private String handoverDate;
}
