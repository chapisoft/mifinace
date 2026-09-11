package com.bmf.mobile.app.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Request sinh mã MMQR động EMVCo cho khoản nợ đến hạn.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenerateMmqrRequest {

    @NotBlank(message = "{validation.loan.code.required}")
    private String loanCode;

    @NotNull(message = "{validation.schedule.id.required}")
    private Long scheduleId;

    @NotNull(message = "{validation.amount.required}")
    @Positive(message = "{validation.amount.positive}")
    private BigDecimal amount;
}
