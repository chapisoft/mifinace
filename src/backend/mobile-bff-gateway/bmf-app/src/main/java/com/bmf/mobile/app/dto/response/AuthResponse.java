package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Phản hồi sau khi xác thực đăng nhập / refresh token thành công.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuthResponse {

    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private Long expiresIn;
    private UserType userType;
    private String userId;
    private String fullName;
    private String branchCode;
    private String groupCode;
    private String centerCode;
    private String township;
    private String deviceId;
    private PlatformType platform;
    private boolean deviceActive;
}
