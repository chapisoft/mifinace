package com.bmf.mobile.app.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * Yêu cầu đồng bộ danh sách mẻ các khoản gạch nợ thu offline khi thiết bị có kết nối mạng trở lại.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu đồng bộ mẻ giao dịch gạch nợ offline")
public class BatchRepaymentSyncRequest {

    @NotEmpty(message = "{validation.loan.batch.notEmpty}")
    @Valid
    @Schema(description = "Danh sách các khoản thu tiền ngoại tuyến")
    private List<CollectRepaymentRequest> repayments;
}
