package com.bmf.mobile.api;

import com.bmf.mobile.domain.constant.AppConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

import java.util.TimeZone;

/**
 * Điểm khởi chạy chính của phân hệ Mobile BFF Gateway (Java 21 LTS & Spring Boot 3.3+).
 */
@Slf4j
@SpringBootApplication
@ComponentScan(basePackages = "com.bmf.mobile")
public class BffApplication {

    public static void main(String[] args) {
        // Đặt múi giờ mặc định Asia/Yangon (UTC+06:30) cho thị trường Myanmar
        TimeZone.setDefault(TimeZone.getTimeZone(AppConstants.DEFAULT_TIMEZONE));
        log.info("Starting BMF Mobile BFF Gateway with TimeZone: {} (Myanmar Time UTC+06:30)", AppConstants.DEFAULT_TIMEZONE);

        SpringApplication.run(BffApplication.class, args);
        log.info("BMF Mobile BFF Gateway started successfully on Java 21 Virtual Threads!");
    }
}
