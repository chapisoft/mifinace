package com.bmf.mobile.api;

import com.bmf.mobile.app.dto.request.DeviceRegisterRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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
class BffApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("Kiểm tra Endpoint /api/v1/health hoạt động và trả về HTTP 200 với i18n mặc định")
    void healthCheckShouldReturn200() throws Exception {
        mockMvc.perform(get("/api/v1/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Mobile BFF Gateway is running normally"))
                .andExpect(jsonPath("$.data.status").value("UP"))
                .andExpect(jsonPath("$.data.serviceName").value("BMF-Mobile-BFF-Gateway"));
    }

    @Test
    @DisplayName("Kiểm tra Endpoint /api/v1/health với Header Accept-Language: vi")
    void healthCheckShouldSupportVietnameseLocale() throws Exception {
        mockMvc.perform(get("/api/v1/health")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Hệ thống Mobile BFF Gateway hoạt động bình thường"));
    }

    @Test
    @DisplayName("Kiểm tra Endpoint /api/v1/health với Header Accept-Language: my (Myanmar)")
    void healthCheckShouldSupportMyanmarLocale() throws Exception {
        mockMvc.perform(get("/api/v1/health")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "my"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Mobile BFF Gateway ပုံမှန် အလုပ်လုပ်နေပါသည်"));
    }

    @Test
    @DisplayName("Kiểm tra GlobalExceptionHandler bắt lỗi Validation và phân giải i18n theo Accept-Language")
    void registerDeviceValidationFailureShouldReturnProblemDetailsWithI18n() throws Exception {
        DeviceRegisterRequest invalidRequest = DeviceRegisterRequest.builder()
                .deviceId("") // Lỗi để trống
                .userId("")   // Lỗi để trống
                .build();

        mockMvc.perform(post("/api/v1/devices/register")
                        .header(HttpHeaders.ACCEPT_LANGUAGE, "vi")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorCode").value("ERR_PARAMETERS_INVALID"))
                .andExpect(jsonPath("$.detail").value("Tham số yêu cầu không hợp lệ hoặc thiếu trường bắt buộc"))
                .andExpect(jsonPath("$.validationErrors").isArray())
                .andExpect(jsonPath("$.traceId").exists());
    }
}
