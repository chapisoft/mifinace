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
 * Request kiểm tra trạng thái tài khoản trong Core Banking và ứng dụng.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CheckAccountRequest {

    @NotBlank(message = "{validation.auth.identifier.notBlank}")
    @Size(max = 64, message = "{validation.auth.identifier.size}")
    private String identifier; // Số điện thoại, số NRC hoặc mã cán bộ

    @NotNull(message = "{validation.auth.userType.notNull}")
    private UserType userType; // CUSTOMER hoặc AGENT
}
