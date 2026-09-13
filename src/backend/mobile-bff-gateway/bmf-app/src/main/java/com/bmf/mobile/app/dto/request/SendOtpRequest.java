package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.UserType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Request gửi mã OTP kích hoạt hoặc quên PIN.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendOtpRequest {

    @NotBlank(message = "{validation.auth.identifier.notBlank}")
    @Size(max = 64, message = "{validation.auth.identifier.size}")
    private String identifier;

    @NotNull(message = "{validation.auth.userType.notNull}")
    private UserType userType;
}
