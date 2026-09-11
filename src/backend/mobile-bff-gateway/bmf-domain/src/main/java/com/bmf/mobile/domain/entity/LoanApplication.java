package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.LoanApplicationStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Thực thể hồ sơ vay vốn và thẩm định tín dụng thực địa.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoanApplication {
    private String applicationId;
    private String customerCode;
    private String customerName;
    private String nrcNumber;
    private String groupCode;
    private String loanProductCode;
    private BigDecimal requestedAmount;
    private Integer termMonths;
    private String purpose;
    private BigDecimal gpsLatitude;
    private BigDecimal gpsLongitude;
    private String nrcFrontImageUrl;
    private String nrcBackImageUrl;
    private String surveyImageUrl;
    private String signatureImageUrl;
    private LoanApplicationStatus status;
    private Integer creditScore;
    private String createdBy;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}
