package com.bmf.mobile.app.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * Chuẩn định dạng phản hồi lỗi theo đặc tả RFC 7807 (Problem Details for HTTP APIs).
 * Tuyệt đối không để lộ stack trace nội bộ ra client và không gán giá trị mặc định ngầm.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {

    private boolean success;
    private String type;                            // URI tham chiếu phân loại lỗi
    private String title;                           // Tiêu đề ngắn gọn của lỗi
    private int status;                             // Mã HTTP Status code
    private String errorCode;                       // Mã lỗi chuẩn Enum hệ thống
    private String detail;                          // Thông điệp chi tiết giải thích cho người dùng / dev
    private String instance;                        // Endpoint đường dẫn phát sinh lỗi
    private String traceId;                         // Mã truy vết SpanId/TraceId dùng đối soát log ECS
    private List<ValidationError> validationErrors; // Danh sách lỗi kiểm tra form nếu có
    private Long timestamp;                         // Thời điểm phát sinh lỗi theo Epoch Millis

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ValidationError {
        private String field;
        private Object rejectedValue;
        private String message;
    }
}
