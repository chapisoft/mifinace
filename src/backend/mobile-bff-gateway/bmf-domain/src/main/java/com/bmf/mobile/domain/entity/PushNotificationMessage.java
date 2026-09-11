package com.bmf.mobile.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Map;

/**
 * Thông điệp thông báo đẩy Firebase FCM gửi đến thiết bị di động.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PushNotificationMessage {

    /**
     * Mã thiết bị hoặc FCM Registration Token.
     */
    private String targetPushToken;

    /**
     * Mã người dùng nhận thông báo (User_ID).
     */
    private String targetUserId;

    /**
     * Tiêu đề thông báo.
     */
    private String title;

    /**
     * Nội dung thông báo (hỗ trợ Myanmar Unicode / Tiếng Anh).
     */
    private String body;

    /**
     * Dữ liệu mở rộng đính kèm (Key-Value) phục vụ Deep Linking.
     */
    private Map<String, String> dataPayload;

    /**
     * Kênh thông báo (Notification Channel ID trên Android).
     */
    private String channelId;
}
