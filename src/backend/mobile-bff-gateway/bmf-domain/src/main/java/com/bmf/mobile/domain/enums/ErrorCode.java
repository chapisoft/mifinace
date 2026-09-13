package com.bmf.mobile.domain.enums;

/**
 * Bảng mã lỗi chuẩn hệ thống Mobile BFF Gateway.
 * Tuyệt đối không sử dụng String literals tự do trong Service hay Controller.
 */
public enum ErrorCode {
    // Nhóm 200 - Thành công
    SUCCESS("SUCCESS", "Thành công", 200),

    // Nhóm 400 - Tham số & Dữ liệu không hợp lệ
    ERR_PARAMETERS_INVALID("ERR_PARAMETERS_INVALID", "Tham số yêu cầu không hợp lệ hoặc thiếu trường bắt buộc", 400),
    ERR_FORMAT_INVALID("ERR_FORMAT_INVALID", "Định dạng dữ liệu không đúng chuẩn", 400),
    ERR_AMOUNT_INVALID("ERR_AMOUNT_INVALID", "Số tiền giao dịch không hợp lệ", 400),
    ERR_NRC_FORMAT_INVALID("ERR_NRC_FORMAT_INVALID", "Số thẻ căn cước NRC không đúng định dạng chuẩn Myanmar", 400),

    // Nhóm 401 - Xác thực & Phiên đăng nhập
    ERR_UNAUTHORIZED("ERR_UNAUTHORIZED", "Yêu cầu chưa được xác thực hoặc phiên đăng nhập đã hết hạn", 401),
    ERR_TOKEN_EXPIRED("ERR_TOKEN_EXPIRED", "Token truy cập đã hết hạn", 401),
    ERR_TOKEN_INVALID("ERR_TOKEN_INVALID", "Token không hợp lệ hoặc chữ ký không chính xác", 401),
    ERR_TOKEN_BLACKLISTED("ERR_TOKEN_BLACKLISTED", "Token đã bị thu hồi hoặc đăng xuất khỏi hệ thống", 401),
    ERR_CREDENTIALS_INVALID("ERR_CREDENTIALS_INVALID", "Tên đăng nhập hoặc mật khẩu / mã PIN không chính xác", 401),
    ERR_PIN_BLOCKED("ERR_PIN_BLOCKED", "Tài khoản bị tạm khóa do nhập sai mã PIN quá số lần quy định", 401),

    // Nhóm 403 - Phân quyền & Ràng buộc thiết bị
    ERR_FORBIDDEN("ERR_FORBIDDEN", "Người dùng không có quyền truy cập tài nguyên này", 403),
    ERR_DEVICE_NOT_REGISTERED("ERR_DEVICE_NOT_REGISTERED", "Thiết bị chưa được đăng ký hoặc chưa được IT kích hoạt", 403),
    ERR_DEVICE_BLOCKED("ERR_DEVICE_BLOCKED", "Thiết bị đã bị khóa an ninh từ quản trị hệ thống", 403),
    ERR_DEVICE_TAMPERED("ERR_DEVICE_TAMPERED", "Thiết bị có dấu hiệu bị bẻ khóa Root/Jailbreak hoặc can thiệp bộ nhớ", 403),

    // Nhóm 404 - Không tìm thấy dữ liệu
    ERR_RESOURCE_NOT_FOUND("ERR_RESOURCE_NOT_FOUND", "Không tìm thấy dữ liệu yêu cầu", 404),
    ERR_USER_NOT_FOUND("ERR_USER_NOT_FOUND", "Không tìm thấy thông tin người dùng trong hệ thống Core", 404),
    ERR_LOAN_NOT_FOUND("ERR_LOAN_NOT_FOUND", "Không tìm thấy hợp đồng vay vốn tương ứng", 404),
    ERR_GROUP_NOT_FOUND("ERR_GROUP_NOT_FOUND", "Không tìm thấy thông tin Cụm/Tổ", 404),

    // Nhóm Kích hoạt tài khoản & OTP
    ERR_ACCOUNT_NOT_ACTIVATED("ERR_ACCOUNT_NOT_ACTIVATED", "Tài khoản chưa được kích hoạt trên ứng dụng di động", 403),
    ERR_ACCOUNT_ALREADY_ACTIVATED("ERR_ACCOUNT_ALREADY_ACTIVATED", "Tài khoản đã được kích hoạt trước đó", 400),
    ERR_OTP_INVALID("ERR_OTP_INVALID", "Mã xác thực OTP không chính xác", 400),
    ERR_OTP_EXPIRED("ERR_OTP_EXPIRED", "Mã xác thực OTP đã hết hạn, vui lòng gửi lại", 400),
    ERR_ACTIVATION_TOKEN_INVALID("ERR_ACTIVATION_TOKEN_INVALID", "Phiên kích hoạt không hợp lệ hoặc đã hết hạn", 401),
    ERR_RESET_TOKEN_INVALID("ERR_RESET_TOKEN_INVALID", "Phiên đặt lại mã PIN không hợp lệ hoặc đã hết hạn", 401),

    // Nhóm 409 - Tranh chấp đồng thời & Trùng lặp Idempotency
    ERR_CONFLICT("ERR_CONFLICT", "Dữ liệu bị xung đột hoặc đang được xử lý bởi tiến trình khác", 409),
    ERR_TRANSACTION_DUPLICATED("ERR_TRANSACTION_DUPLICATED", "Giao dịch đã được tiếp nhận và xử lý trước đó", 409),
    ERR_RESOURCE_LOCKED("ERR_RESOURCE_LOCKED", "Tài nguyên đang bị khóa bởi giao dịch đồng thời khác, vui lòng thử lại sau", 409),
    ERR_TRANSACTION_ALREADY_SETTLED("ERR_TRANSACTION_ALREADY_SETTLED", "Món nợ này đã được gạch nợ thành công", 409),

    // Nhóm 429 - Vượt hạn mức gọi API
    ERR_TOO_MANY_REQUESTS("ERR_TOO_MANY_REQUESTS", "Vượt quá tần suất gọi API cho phép, vui lòng thử lại sau", 429),

    // Nhóm 401 & 404 & 400 Thanh toán số
    ERR_PAYMENT_SIGNATURE_INVALID("ERR_PAYMENT_SIGNATURE_INVALID", "Chữ ký số xác thực webhook ví điện tử không hợp lệ", 401),
    ERR_PAYMENT_ORDER_NOT_FOUND("ERR_PAYMENT_ORDER_NOT_FOUND", "Không tìm thấy yêu cầu thanh toán", 404),
    ERR_PAYMENT_ORDER_EXPIRED("ERR_PAYMENT_ORDER_EXPIRED", "Yêu cầu thanh toán đã hết hạn, vui lòng tạo mã MMQR mới", 400),

    // Nhóm 500 - Lỗi máy chủ & Hệ thống ngoài
    ERR_INTERNAL_SERVER("ERR_INTERNAL_SERVER", "Lỗi nội bộ hệ thống Mobile BFF Gateway", 500),
    ERR_CORE_WCF_CONNECTION("ERR_CORE_WCF_CONNECTION", "Không thể kết nối đến dịch vụ Core Banking WCF", 502),
    ERR_CORE_WCF_TIMEOUT("ERR_CORE_WCF_TIMEOUT", "Quá thời gian chờ phản hồi từ Core Banking WCF", 504),
    ERR_DATABASE_ERROR("ERR_DATABASE_ERROR", "Lỗi truy vấn cơ sở dữ liệu SQL Server", 500),
    ERR_REDIS_CONNECTION("ERR_REDIS_CONNECTION", "Lỗi kết nối bộ nhớ đệm phân tán Redis", 500),
    ERR_EXTERNAL_GATEWAY("ERR_EXTERNAL_GATEWAY", "Lỗi kết nối cổng thanh toán ví điện tử đối tác", 502);

    private final String code;
    private final String defaultMessage;
    private final int httpStatus;

    ErrorCode(String code, String defaultMessage, int httpStatus) {
        this.code = code;
        this.defaultMessage = defaultMessage;
        this.httpStatus = httpStatus;
    }

    public String getCode() {
        return code;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }

    public int getHttpStatus() {
        return httpStatus;
    }
}
