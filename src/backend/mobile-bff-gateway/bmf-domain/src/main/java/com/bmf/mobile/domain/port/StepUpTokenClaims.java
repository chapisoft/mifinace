package com.bmf.mobile.domain.port;

import com.bmf.mobile.domain.enums.UserType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO chứa thông tin đã xác thực từ Step-Up Token (Activation Token hoặc Reset PIN Token).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StepUpTokenClaims {

    private String jti;
    private String businessId;
    private UserType userType;
    private String purpose;
    private String identifier;
    private long remainingTtlSeconds;
}
