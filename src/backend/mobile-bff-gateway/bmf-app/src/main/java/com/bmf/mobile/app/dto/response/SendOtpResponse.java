package com.bmf.mobile.app.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Phản hồi sau khi phát sinh mã OTP bảo mật.
 * Tuyệt đối KHÔNG trả về mã OTP dạng rõ trong response để đảm bảo an toàn tài chính.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SendOtpResponse {

    private String identifier;
    private String maskedPhone;
    private int expiresIn;
    private long cooldownSeconds;
}
