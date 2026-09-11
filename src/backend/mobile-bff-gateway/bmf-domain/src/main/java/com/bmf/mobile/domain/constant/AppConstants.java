package com.bmf.mobile.domain.constant;

/**
 * Hằng số cấu hình kỹ thuật hệ thống Mobile BFF Gateway.
 */
public final class AppConstants {

    private AppConstants() {
        // Chống khởi tạo instance
    }

    public static final String DEFAULT_TIMEZONE = "Asia/Yangon";
    public static final String HEADER_TRACE_ID = "X-Trace-Id";
    public static final String MDC_TRACE_ID = "traceId";
    public static final String ERROR_URI_PREFIX = "https://api.bmf.mm/errors/";
    public static final String SERVICE_NAME = "BMF-Mobile-BFF-Gateway";
}
