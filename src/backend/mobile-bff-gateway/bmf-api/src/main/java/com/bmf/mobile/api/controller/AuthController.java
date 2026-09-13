package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.ActivateAccountRequest;
import com.bmf.mobile.app.dto.request.AgentLoginRequest;
import com.bmf.mobile.app.dto.request.CheckAccountRequest;
import com.bmf.mobile.app.dto.request.CustomerLoginRequest;
import com.bmf.mobile.app.dto.request.LogoutRequest;
import com.bmf.mobile.app.dto.request.RefreshTokenRequest;
import com.bmf.mobile.app.dto.request.ResetPinRequest;
import com.bmf.mobile.app.dto.request.SendOtpRequest;
import com.bmf.mobile.app.dto.request.VerifyOtpRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.app.dto.response.CheckAccountResponse;
import com.bmf.mobile.app.dto.response.SendOtpResponse;
import com.bmf.mobile.app.dto.response.VerifyOtpResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.app.usecase.AccountActivationUseCase;
import com.bmf.mobile.app.usecase.AgentAuthenticationUseCase;
import com.bmf.mobile.app.usecase.CheckAccountUseCase;
import com.bmf.mobile.app.usecase.CustomerAuthenticationUseCase;
import com.bmf.mobile.app.usecase.ForgotPinUseCase;
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
 * Controller quản lý toàn bộ quy trình xác thực, đăng nhập, làm mới Token, đăng xuất,
 * kiểm tra tài khoản Core Banking, kích hoạt tài khoản lần đầu qua OTP và quên mã PIN.
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "02. Authentication & Session Management", description = "Xác thực đăng nhập Cán bộ/Khách hàng, cấp Token JWT và quản lý phiên")
public class AuthController {

    private final CheckAccountUseCase checkAccountUseCase;
    private final AccountActivationUseCase accountActivationUseCase;
    private final ForgotPinUseCase forgotPinUseCase;
    private final AgentAuthenticationUseCase agentAuthenticationUseCase;
    private final CustomerAuthenticationUseCase customerAuthenticationUseCase;
    private final TokenRefreshUseCase tokenRefreshUseCase;
    private final LogoutUseCase logoutUseCase;
    private final I18nService i18nService;

    @PostMapping("/check-account")
    @Operation(summary = "Kiểm tra trạng thái tài khoản trong Core Banking và ứng dụng (Chưa kích hoạt / Đã kích hoạt)")
    public ResponseEntity<ApiResponse<CheckAccountResponse>> checkAccount(
            @Valid @RequestBody CheckAccountRequest request) {

        CheckAccountResponse response = checkAccountUseCase.checkAccount(request);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/activation/send-otp")
    @Operation(summary = "Gửi mã OTP xác thực kích hoạt tài khoản App lần đầu")
    public ResponseEntity<ApiResponse<SendOtpResponse>> sendActivationOtp(
            @Valid @RequestBody SendOtpRequest request) {

        SendOtpResponse response = accountActivationUseCase.sendActivationOtp(request);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/activation/verify-otp")
    @Operation(summary = "Xác thực mã OTP kích hoạt và nhận Step-Up Token (10 phút)")
    public ResponseEntity<ApiResponse<VerifyOtpResponse>> verifyActivationOtp(
            @Valid @RequestBody VerifyOtpRequest request) {

        VerifyOtpResponse response = accountActivationUseCase.verifyActivationOtp(request);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/activation/set-pin")
    @Operation(summary = "Thiết lập mã PIN 6 số lần đầu, kích hoạt AppUser và đăng nhập")
    public ResponseEntity<ApiResponse<AuthResponse>> activateAccount(
            @Valid @RequestBody ActivateAccountRequest request) {

        AuthResponse response = accountActivationUseCase.activateAccount(request);
        String message = i18nService.getMessage("msg.auth.login.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/forgot-pin/send-otp")
    @Operation(summary = "Gửi mã OTP xác thực để đặt lại mã PIN")
    public ResponseEntity<ApiResponse<SendOtpResponse>> sendForgotPinOtp(
            @Valid @RequestBody SendOtpRequest request) {

        SendOtpResponse response = forgotPinUseCase.sendForgotPinOtp(request);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/forgot-pin/verify-otp")
    @Operation(summary = "Xác thực mã OTP quên PIN và nhận Step-Up Token đặt lại PIN")
    public ResponseEntity<ApiResponse<VerifyOtpResponse>> verifyForgotPinOtp(
            @Valid @RequestBody VerifyOtpRequest request) {

        VerifyOtpResponse response = forgotPinUseCase.verifyForgotPinOtp(request);
        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

    @PostMapping("/forgot-pin/reset-pin")
    @Operation(summary = "Thiết lập mã PIN mới sau khi xác thực OTP thành công")
    public ResponseEntity<ApiResponse<AuthResponse>> resetPin(
            @Valid @RequestBody ResetPinRequest request) {

        AuthResponse response = forgotPinUseCase.resetPin(request);
        String message = i18nService.getMessage("msg.auth.login.success");
        return ResponseEntity.ok(ApiResponse.ok(response, message));
    }

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
