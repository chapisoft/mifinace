package com.bmf.mobile.app.dto.request;

import com.bmf.mobile.domain.enums.UserType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * Request xác thực mã OTP người dùng nhập vào.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "otpCode")
public class VerifyOtpRequest {

    @NotBlank(message = "{validation.auth.identifier.notBlank}")
    @Size(max = 64, message = "{validation.auth.identifier.size}")
    private String identifier;

    @NotNull(message = "{validation.auth.userType.notNull}")
    private UserType userType;

    @NotBlank(message = "{validation.auth.otp.notBlank}")
    @Pattern(regexp = "^[0-9]{6}$", message = "{validation.auth.otp.format}")
    private String otpCode;
}
