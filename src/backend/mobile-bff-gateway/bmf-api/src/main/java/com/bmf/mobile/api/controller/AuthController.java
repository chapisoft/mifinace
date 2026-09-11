package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.AgentLoginRequest;
import com.bmf.mobile.app.dto.request.CustomerLoginRequest;
import com.bmf.mobile.app.dto.request.LogoutRequest;
import com.bmf.mobile.app.dto.request.RefreshTokenRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.AgentAuthenticationUseCase;
import com.bmf.mobile.app.usecase.CustomerAuthenticationUseCase;
import com.bmf.mobile.app.usecase.LogoutUseCase;
import com.bmf.mobile.app.usecase.TokenRefreshUseCase;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller quản lý toàn bộ quy trình xác thực, đăng nhập, làm mới Token và đăng xuất.
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "02. Authentication & Session Management", description = "Xác thực đăng nhập Cán bộ/Khách hàng, cấp Token JWT và quản lý phiên")
public class AuthController {

    private final AgentAuthenticationUseCase agentAuthenticationUseCase;
    private final CustomerAuthenticationUseCase customerAuthenticationUseCase;
    private final TokenRefreshUseCase tokenRefreshUseCase;
    private final LogoutUseCase logoutUseCase;
    private final I18nService i18nService;

    @PostMapping("/agent-login")
    @Operation(summary = "Đăng nhập Cán bộ tín dụng (Loan Officer / Agent)")
    public ResponseEntity<ApiResponse<AuthResponse>> agentLogin(
            @Valid @RequestBody AgentLoginRequest request) {

        AuthResponse response = agentAuthenticationUseCase.authenticate(request);
        String message = i18nService.getMessage("msg.auth.login.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/customer-login")
    @Operation(summary = "Đăng nhập Khách hàng thành viên qua số thẻ NRC và mã PIN")
    public ResponseEntity<ApiResponse<AuthResponse>> customerLogin(
            @Valid @RequestBody CustomerLoginRequest request) {

        AuthResponse response = customerAuthenticationUseCase.authenticate(request);
        String message = i18nService.getMessage("msg.auth.login.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "Làm mới Access Token (Token Rotation)")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request) {

        AuthResponse response = tokenRefreshUseCase.refresh(request);
        String message = i18nService.getMessage("msg.auth.refresh.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/logout")
    @Operation(summary = "Đăng xuất và vô hiệu hóa Token phiên làm việc")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestBody(required = false) LogoutRequest request,
            @RequestHeader(value = "Authorization", required = false) String bearerToken) {

        logoutUseCase.logout(request, bearerToken);
        String message = i18nService.getMessage("msg.auth.logout.success");
        return ResponseEntity.ok(ApiResponse.ok(null, message));
    }
}
