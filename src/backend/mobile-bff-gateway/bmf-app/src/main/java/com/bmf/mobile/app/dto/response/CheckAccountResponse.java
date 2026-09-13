package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.enums.UserType;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Phản hồi trạng thái tài khoản trong Core Banking & App.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CheckAccountResponse {

    private String status; // "ACTIVATED" (Đã kích hoạt) hoặc "NOT_ACTIVATED" (Chưa kích hoạt)
    private String identifier;
    private String businessId;
    private UserType userType;
    private String fullName;
    private String maskedPhone; // Ví dụ: "09****2345"
    private String nrcNumber;
    private boolean activated;
    private boolean biometricEnabled;
    private boolean pinLocked;
}
