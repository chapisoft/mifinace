package com.bmf.mobile.app.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Yêu cầu xác nhận nhận bàn giao quỹ tiền mặt tại quầy (Thủ quỹ).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu xác nhận đối soát bàn giao quỹ tiền mặt")
public class ConfirmCashHandoverRequest {

    @NotBlank(message = "{validation.handover.id.required}")
    @Schema(description = "Mã biên bản bàn giao quỹ", example = "HO-20260915-USR001")
    private String handoverId;

    @NotBlank(message = "{validation.handover.qrPayload.required}")
    @Schema(description = "Dữ liệu QR quét được từ máy cán bộ", example = "BMF_HANDOVER:HO-20260915-USR001|1250000.00|25|SIG_a8b9c0...")
    private String qrPayload;
}
