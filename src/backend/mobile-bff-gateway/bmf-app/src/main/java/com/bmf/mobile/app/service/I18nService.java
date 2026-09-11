package com.bmf.mobile.app.service;

import java.util.Locale;

/**
 * Cổng giao tiếp phân giải thông điệp đa ngôn ngữ (i18n).
 * Đảm bảo 100% Zero-Hardcode thông điệp trong toàn hệ thống.
 */
public interface I18nService {

    /**
     * Phân giải thông điệp theo mã định danh (key) với Locale hiện tại của request.
     *
     * @param code mã định danh thông điệp / mã lỗi
     * @param args tham số định dạng
     * @return thông điệp đã được địa phương hóa
     */
    String getMessage(String code, Object... args);

    /**
     * Phân giải thông điệp với Locale chỉ định cụ thể.
     *
     * @param code   mã định danh thông điệp
     * @param locale ngôn ngữ chỉ định
     * @param args   tham số định dạng
     * @return thông điệp đã được địa phương hóa
     */
    String getMessage(String code, Locale locale, Object... args);
}
