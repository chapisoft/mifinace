package com.bmf.mobile.domain.port;

/**
 * Cổng giao tiếp mã hóa và kiểm tra mật khẩu (Domain Port).
 */
public interface PasswordEncoderPort {

    /**
     * Mã hóa mật khẩu thô.
     */
    String encode(CharSequence rawPassword);

    /**
     * Kiểm tra mật khẩu thô có khớp với chuỗi băm hay không.
     */
    boolean matches(CharSequence rawPassword, String encodedPassword);
}
