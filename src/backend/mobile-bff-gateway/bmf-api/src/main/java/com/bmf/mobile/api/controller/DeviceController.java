package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.request.DeviceRegisterRequest;
import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.dto.response.DeviceRegisterResponse;
import com.bmf.mobile.app.usecase.DeviceRegistrationUseCase;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller quản lý đăng ký và kiểm soát ràng buộc thiết bị di động (Device Binding).
 */
@RestController
@RequestMapping("/api/v1/devices")
@RequiredArgsConstructor
@Tag(name = "01. Mobile Device Management", description = "Quản lý thiết bị di động, ràng buộc phần cứng và Push Token")
public class DeviceController {

    private final DeviceRegistrationUseCase deviceRegistrationUseCase;

    @PostMapping("/register")
    @Operation(summary = "Đăng ký hoặc cập nhật thiết bị di động và FCM Push Token")
    public ResponseEntity<ApiResponse<DeviceRegisterResponse>> registerDevice(
            @Valid @RequestBody DeviceRegisterRequest request) {

        DeviceRegisterResponse response = deviceRegistrationUseCase.registerOrUpdate(request);
        return ResponseEntity.ok(ApiResponse.ok(response, response.getMessage()));
    }
}
