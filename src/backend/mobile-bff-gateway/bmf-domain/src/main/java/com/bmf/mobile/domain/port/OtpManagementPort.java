package com.bmf.mobile.domain.port;

import com.bmf.mobile.domain.enums.UserType;

/**
 * Cổng giao tiếp xử lý nghiệp vụ bảo mật OTP và Step-Up Token (Domain Port).
 */
public interface OtpManagementPort {

    /**
     * Sinh và lưu mã OTP bảo mật trên Redis với thời hạn TTL.
     * @return Mã OTP sinh ra (để gửi qua SMS Gateway)
     */
    String generateAndStoreOtp(String identifier, String purpose, String phoneNumber, int ttlSeconds);

    /**
     * Xác thực mã OTP người dùng nhập vào.
     * Tự động xóa OTP sau khi xác thực thành công hoặc khóa khi sai quá 3 lần.
     */
    boolean verifyOtp(String identifier, String purpose, String otpCode);

    /**
     * Kiểm tra cool-down giữa các lần yêu cầu gửi lại OTP.
     */
    boolean isOtpCoolingDown(String identifier, String purpose);

    /**
     * Lấy thời gian cool-down còn lại tính bằng giây.
     */
    long getRemainingCooldown(String identifier, String purpose);

    /**
     * Sinh Step-Up JWT Token ngắn hạn sau khi OTP được xác thực thành công.
     */
    String generateStepUpToken(String businessId, UserType userType, String purpose, String identifier);

    /**
     * Xác thực và thu hồi (vô hiệu hóa một lần) Step-Up Token.
     */
    StepUpTokenClaims validateAndConsumeStepUpToken(String token, String expectedPurpose);
}
