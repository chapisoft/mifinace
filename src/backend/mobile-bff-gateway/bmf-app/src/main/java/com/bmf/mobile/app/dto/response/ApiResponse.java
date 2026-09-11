package com.bmf.mobile.app.dto.response;

import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.slf4j.MDC;

import java.time.Instant;

/**
 * Chuẩn định dạng phản hồi RESTful API chung cho toàn hệ thống Mobile BFF Gateway.
 * 100% Zero-Hardcode & Zero Fake Default Values: sử dụng ErrorCode enum và không gán giá trị giả lập ngầm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private boolean success;
    private String code;
    private String message;
    private T data;
    private String traceId;
    private Long timestamp;

    public static <T> ApiResponse<T> ok(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .code(ErrorCode.SUCCESS.getCode())
                .data(data)
                .traceId(MDC.get(AppConstants.MDC_TRACE_ID))
                .timestamp(Instant.now().toEpochMilli())
                .build();
    }

    public static <T> ApiResponse<T> ok(T data, String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .code(ErrorCode.SUCCESS.getCode())
                .message(message)
                .data(data)
                .traceId(MDC.get(AppConstants.MDC_TRACE_ID))
                .timestamp(Instant.now().toEpochMilli())
                .build();
    }
}
