package com.bmf.mobile.api.exception;

import com.bmf.mobile.app.dto.response.ErrorResponse;
import com.bmf.mobile.app.service.I18nService;
import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.exception.BusinessException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Xử lý tập trung toàn bộ ngoại lệ hệ thống theo chuẩn RFC 7807 (Problem Details).
 * Tích hợp 100% phân giải đa ngôn ngữ qua I18nService và tuyệt đối Zero-Hardcode.
 */
@Slf4j
@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final I18nService i18nService;

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException ex, HttpServletRequest request) {
        String traceId = getOrCreateTraceId();
        ErrorCode errorCode = ex.getErrorCode();

        String localizedDetail = i18nService.getMessage("error." + errorCode.getCode());
        if (ex.getMessage() != null && !ex.getMessage().isBlank() && !ex.getMessage().equals(errorCode.getDefaultMessage())) {
            localizedDetail = ex.getMessage();
        }

        log.warn("[{}] Business Exception: code={}, message={}, path={}",
                traceId, errorCode.getCode(), localizedDetail, request.getRequestURI());

        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + errorCode.getCode().toLowerCase())
                .title(errorCode.getCode())
                .status(errorCode.getHttpStatus())
                .errorCode(errorCode.getCode())
                .detail(localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        return ResponseEntity.status(errorCode.getHttpStatus()).body(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException ex, HttpServletRequest request) {
        String traceId = getOrCreateTraceId();
        List<ErrorResponse.ValidationError> validationErrors = new ArrayList<>();

        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            validationErrors.add(ErrorResponse.ValidationError.builder()
                    .field(fieldError.getField())
                    .rejectedValue(fieldError.getRejectedValue())
                    .message(fieldError.getDefaultMessage())
                    .build());
        }

        log.warn("[{}] Validation Error on path={}: {} errors", traceId, request.getRequestURI(), validationErrors.size());

        String localizedDetail = i18nService.getMessage("error." + ErrorCode.ERR_PARAMETERS_INVALID.getCode());

        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + "validation-error")
                .title(ErrorCode.ERR_PARAMETERS_INVALID.getCode())
                .status(HttpStatus.BAD_REQUEST.value())
                .errorCode(ErrorCode.ERR_PARAMETERS_INVALID.getCode())
                .detail(localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .validationErrors(validationErrors)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(IllegalArgumentException ex, HttpServletRequest request) {
        String traceId = getOrCreateTraceId();

        log.warn("[{}] Illegal Argument on path={}: {}", traceId, request.getRequestURI(), ex.getMessage());

        String localizedDetail = i18nService.getMessage("error." + ErrorCode.ERR_PARAMETERS_INVALID.getCode());

        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + "invalid-argument")
                .title(ErrorCode.ERR_PARAMETERS_INVALID.getCode())
                .status(HttpStatus.BAD_REQUEST.value())
                .errorCode(ErrorCode.ERR_PARAMETERS_INVALID.getCode())
                .detail(ex.getMessage() != null ? ex.getMessage() : localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @ExceptionHandler(org.springframework.security.access.AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDeniedException(org.springframework.security.access.AccessDeniedException ex, HttpServletRequest request) {
        String traceId = getOrCreateTraceId();
        ErrorCode errorCode = ErrorCode.ERR_FORBIDDEN;
        String localizedDetail = i18nService.getMessage("error." + errorCode.getCode());

        log.warn("[{}] Access Denied on path={}: {}", traceId, request.getRequestURI(), ex.getMessage());

        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + errorCode.getCode().toLowerCase())
                .title(errorCode.getCode())
                .status(HttpStatus.FORBIDDEN.value())
                .errorCode(errorCode.getCode())
                .detail(localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
    }

    @ExceptionHandler(org.springframework.security.core.AuthenticationException.class)
    public ResponseEntity<ErrorResponse> handleAuthenticationException(org.springframework.security.core.AuthenticationException ex, HttpServletRequest request) {
        String traceId = getOrCreateTraceId();
        ErrorCode errorCode = ErrorCode.ERR_UNAUTHORIZED;
        String localizedDetail = i18nService.getMessage("error." + errorCode.getCode());

        log.warn("[{}] Authentication Exception on path={}: {}", traceId, request.getRequestURI(), ex.getMessage());

        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + errorCode.getCode().toLowerCase())
                .title(errorCode.getCode())
                .status(HttpStatus.UNAUTHORIZED.value())
                .errorCode(errorCode.getCode())
                .detail(localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneralException(Exception ex, HttpServletRequest request) {
        String traceId = getOrCreateTraceId();

        log.error("[{}] Internal Server Error on path={}", traceId, request.getRequestURI(), ex);

        String localizedDetail = i18nService.getMessage("error." + ErrorCode.ERR_INTERNAL_SERVER.getCode());

        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .type(AppConstants.ERROR_URI_PREFIX + "internal-server-error")
                .title(ErrorCode.ERR_INTERNAL_SERVER.getCode())
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .errorCode(ErrorCode.ERR_INTERNAL_SERVER.getCode())
                .detail(localizedDetail)
                .instance(request.getRequestURI())
                .traceId(traceId)
                .timestamp(Instant.now().toEpochMilli())
                .build();

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    private String getOrCreateTraceId() {
        String traceId = MDC.get(AppConstants.MDC_TRACE_ID);
        if (traceId == null || traceId.isBlank()) {
            traceId = UUID.randomUUID().toString();
            MDC.put(AppConstants.MDC_TRACE_ID, traceId);
        }
        return traceId;
    }
}
