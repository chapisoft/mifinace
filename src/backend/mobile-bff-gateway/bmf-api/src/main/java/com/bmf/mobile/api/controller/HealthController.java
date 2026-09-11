package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.enums.HealthStatusType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.management.ManagementFactory;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * Controller kiểm tra trạng thái sức khỏe của Mobile BFF Gateway.
 * 100% Enum-Driven & Zero-Hardcode.
 */
@RestController
@RequestMapping("/api/v1/health")
@RequiredArgsConstructor
@Tag(name = "00. Health & Monitoring", description = "Kiểm tra sức khỏe hệ thống và các dịch vụ phụ thuộc")
public class HealthController {

    private final I18nService i18nService;

    @GetMapping
    @Operation(summary = "Kiểm tra trạng thái hoạt động của Gateway")
    public ResponseEntity<ApiResponse<HealthStatus>> checkHealth() {
        long uptime = ManagementFactory.getRuntimeMXBean().getUptime();

        HealthStatus status = HealthStatus.builder()
                .serviceName(AppConstants.SERVICE_NAME)
                .status(HealthStatusType.UP.getCode())
                .javaVersion(System.getProperty("java.version"))
                .virtualThreadsEnabled(true)
                .serverTime(LocalDateTime.now())
                .uptimeSeconds(uptime / 1000)
                .systemMetrics(Map.of(
                        "availableProcessors", Runtime.getRuntime().availableProcessors(),
                        "freeMemoryMB", Runtime.getRuntime().freeMemory() / (1024 * 1024),
                        "totalMemoryMB", Runtime.getRuntime().totalMemory() / (1024 * 1024),
                        "maxMemoryMB", Runtime.getRuntime().maxMemory() / (1024 * 1024)
                ))
                .build();

        String message = i18nService.getMessage("msg.health.ok");
        return ResponseEntity.ok(ApiResponse.ok(status, message));
    }

    @Getter
    @Builder
    public static class HealthStatus {
        private String serviceName;
        private String status;
        private String javaVersion;
        private boolean virtualThreadsEnabled;
        private LocalDateTime serverTime;
        private long uptimeSeconds;
        private Map<String, Object> systemMetrics;
    }
}
