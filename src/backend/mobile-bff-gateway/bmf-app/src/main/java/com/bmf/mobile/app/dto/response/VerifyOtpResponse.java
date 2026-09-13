package com.bmf.mobile.app.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Phản hồi sau khi xác thực OTP thành công, cấp Step-Up Token dùng 1 lần (One-Time Token).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class VerifyOtpResponse {

    private String stepUpToken;
    private String purpose; // "ACTIVATION" hoặc "RESET_PIN"
    private int expiresIn; // Thời gian sống tính theo giây (ví dụ: 600s)
}
