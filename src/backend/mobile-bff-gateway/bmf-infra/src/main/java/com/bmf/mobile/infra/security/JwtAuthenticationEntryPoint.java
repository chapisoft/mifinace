package com.bmf.mobile.infra.security;

import com.bmf.mobile.app.dto.response.ErrorResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.Instant;
import java.util.UUID;

/**
 * Xử lý khi truy cập tài nguyên bảo vệ mà chưa được xác thực (HTTP 401 Unauthorized).
 * Trả về phản hồi lỗi theo đúng chuẩn RFC 7807 Problem Details và phân giải đa ngôn ngữ qua I18nService.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final I18nService i18nService;
    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException)
            throws IOException {

        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);
        if (traceId == null || traceId.isBlank()) {
            traceId = UUID.randomUUID().toString();
            MDC.put(AppConstants.MDC_TRACE_ID, traceId);
        }

        log.warn("[{}] Unauthorized access attempt on path={}: {}",
                traceId, request.getRequestURI(), authException.getMessage());

        String localizedDetail = i18nService.getMessage("error." + ErrorCode.ERR_UNAUTHORIZED.getCode());

        ErrorResponse errorResponse = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + "unauthorized")
                .title(ErrorCode.ERR_UNAUTHORIZED.getCode())
                .status(HttpStatus.UNAUTHORIZED.value())
                .errorCode(ErrorCode.ERR_UNAUTHORIZED.getCode())
                .detail(localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(errorResponse));
    }
}
