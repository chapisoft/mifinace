package com.bmf.mobile.api;

import com.bmf.mobile.app.dto.request.AgentLoginRequest;
import com.bmf.mobile.app.dto.request.CustomerLoginRequest;
import com.bmf.mobile.app.dto.request.LogoutRequest;
import com.bmf.mobile.app.dto.request.RefreshTokenRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.app.usecase.AgentAuthenticationUseCase;
import com.bmf.mobile.app.usecase.CustomerAuthenticationUseCase;
import com.bmf.mobile.app.usecase.LogoutUseCase;
import com.bmf.mobile.app.usecase.TokenRefreshUseCase;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.springframework.context.annotation.Import;

@SpringBootTest(properties = {
        "spring.autoconfigure.exclude=org.redisson.spring.starter.RedissonAutoConfigurationV2"
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestConfig.class)
@SuppressWarnings("null")
class AuthIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AgentAuthenticationUseCase agentAuthenticationUseCase;

    @MockBean
    private CustomerAuthenticationUseCase customerAuthenticationUseCase;

    @MockBean
    private TokenRefreshUseCase tokenRefreshUseCase;

    @MockBean
    private LogoutUseCase logoutUseCase;

    @Test
    @DisplayName("Endpoint POST /api/v1/auth/agent-login thành công trả về 200 kèm Token")
    void agentLoginSuccessShouldReturn200() throws Exception {
        AgentLoginRequest request = AgentLoginRequest.builder()
                .username("BMF_OFFICER_01")
                .password("Password@2026")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .appVersion("1.0.0")
                .build();

        AuthResponse authResponse = AuthResponse.builder()
                .accessToken("ACCESS_TOKEN_SAMPLE_123")
                .refreshToken("REFRESH_TOKEN_SAMPLE_456")
                .tokenType("Bearer")
                .expiresIn(900L)
                .userType(UserType.AGENT)
                .userId("USR001")
                .fullName("U Aung Kyaw")
                .branchCode("BR001")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .deviceActive(true)
                .build();

        when(agentAuthenticationUseCase.authenticate(any(AgentLoginRequest.class))).thenReturn(authResponse);

        mockMvc.perform(post("/api/v1/auth/agent-login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Login successful"))
                .andExpect(jsonPath("$.data.accessToken").value("ACCESS_TOKEN_SAMPLE_123"))
                .andExpect(jsonPath("$.data.userType").value("AGENT"))
                .andExpect(jsonPath("$.data.userId").value("USR001"))
                .andExpect(jsonPath("$.data.fullName").value("U Aung Kyaw"));
    }

    @Test
    @DisplayName("Endpoint POST /api/v1/auth/agent-login thất bại khi sai mật khẩu trả về 401 RFC 7807")
    void agentLoginFailureShouldReturn401ProblemDetails() throws Exception {
        AgentLoginRequest request = AgentLoginRequest.builder()
                .username("BMF_OFFICER_01")
                .password("WrongPassword")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .appVersion("1.0.0")
                .build();

        when(agentAuthenticationUseCase.authenticate(any(AgentLoginRequest.class)))
                .thenThrow(new BusinessException(ErrorCode.ERR_CREDENTIALS_INVALID));

        mockMvc.perform(post("/api/v1/auth/agent-login")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorCode").value("ERR_CREDENTIALS_INVALID"))
                .andExpect(jsonPath("$.detail").value("Tên đăng nhập hoặc mật khẩu / mã PIN không chính xác"))
                .andExpect(jsonPath("$.traceId").exists());
    }

    @Test
    @DisplayName("Endpoint POST /api/v1/auth/customer-login thành công với Accept-Language: my")
    void customerLoginSuccessWithMyanmarLocaleShouldReturn200() throws Exception {
        CustomerLoginRequest request = CustomerLoginRequest.builder()
                .nrcNumber("12/DAGAMA(N)123456")
                .pinCode("123456")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .appVersion("1.0.0")
                .build();

        AuthResponse authResponse = AuthResponse.builder()
                .accessToken("CUSTOMER_ACCESS_TOKEN_SAMPLE")
                .refreshToken("CUSTOMER_REFRESH_TOKEN_SAMPLE")
                .tokenType("Bearer")
                .expiresIn(900L)
                .userType(UserType.CUSTOMER)
                .userId("CUST-99001")
                .fullName("Daw Khin Myint")
                .groupCode("GRP-YGN-01")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .deviceActive(true)
                .build();

        when(customerAuthenticationUseCase.authenticate(any(CustomerLoginRequest.class))).thenReturn(authResponse);

        mockMvc.perform(post("/api/v1/auth/customer-login")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "my")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("အကောင့်ဝင်ရောက်မှု အောင်မြင်ပါသည်"))
                .andExpect(jsonPath("$.data.userType").value("CUSTOMER"))
                .andExpect(jsonPath("$.data.userId").value("CUST-99001"));
    }

    @Test
    @DisplayName("Endpoint POST /api/v1/auth/customer-login khi PIN bị khóa 15 phút trả về 401 Unauthorized")
    void customerLoginLockedPinShouldReturnPinBlockedError() throws Exception {
        CustomerLoginRequest request = CustomerLoginRequest.builder()
                .nrcNumber("12/DAGAMA(N)123456")
                .pinCode("123456")
                .deviceId("DEV-CUST-001")
                .platform(PlatformType.ANDROID)
                .appVersion("1.0.0")
                .build();

        when(customerAuthenticationUseCase.authenticate(any(CustomerLoginRequest.class)))
                .thenThrow(new BusinessException(ErrorCode.ERR_PIN_BLOCKED));

        mockMvc.perform(post("/api/v1/auth/customer-login")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorCode").value("ERR_PIN_BLOCKED"))
                .andExpect(jsonPath("$.detail").value("Tài khoản bị tạm khóa do nhập sai mã PIN quá số lần quy định"));
    }

    @Test
    @DisplayName("Endpoint POST /api/v1/auth/refresh-token thành công (Token Rotation)")
    void refreshTokenSuccessShouldReturn200() throws Exception {
        RefreshTokenRequest request = RefreshTokenRequest.builder()
                .refreshToken("VALID_REFRESH_TOKEN")
                .deviceId("DEV-001")
                .build();

        AuthResponse authResponse = AuthResponse.builder()
                .accessToken("NEW_ROTATED_ACCESS_TOKEN")
                .refreshToken("NEW_ROTATED_REFRESH_TOKEN")
                .tokenType("Bearer")
                .expiresIn(900L)
                .userType(UserType.AGENT)
                .userId("USR001")
                .deviceId("DEV-001")
                .platform(PlatformType.ANDROID)
                .deviceActive(true)
                .build();

        when(tokenRefreshUseCase.refresh(any(RefreshTokenRequest.class))).thenReturn(authResponse);

        mockMvc.perform(post("/api/v1/auth/refresh-token")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Token refreshed successfully"))
                .andExpect(jsonPath("$.data.accessToken").value("NEW_ROTATED_ACCESS_TOKEN"))
                .andExpect(jsonPath("$.data.refreshToken").value("NEW_ROTATED_REFRESH_TOKEN"));
    }

    @Test
    @DisplayName("Endpoint POST /api/v1/auth/logout thành công trả về 200")
    void logoutSuccessShouldReturn200() throws Exception {
        LogoutRequest request = LogoutRequest.builder()
                .refreshToken("REFRESH_TOKEN_TO_REVOKE")
                .build();

        doNothing().when(logoutUseCase).logout(any(LogoutRequest.class), any());

        mockMvc.perform(post("/api/v1/auth/logout")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer CURRENT_ACCESS_TOKEN")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Logged out successfully"));
    }
}
