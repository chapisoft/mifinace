package com.bmf.mobile.app.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Request làm mới Access Token bằng Refresh Token.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefreshTokenRequest {

    @NotBlank(message = "{validation.auth.refreshToken.notBlank}")
    private String refreshToken;

    @NotBlank(message = "{validation.device.deviceId.notBlank}")
    private String deviceId;
}
