package com.bmf.mobile.domain.port;

import com.bmf.mobile.domain.entity.PushNotificationMessage;

import java.util.List;
import java.util.Map;

/**
 * Cổng giao tiếp đẩy thông báo thời gian thực qua Firebase Cloud Messaging (FCM HTTP/2).
 */
public interface PushNotificationPort {

    /**
     * Gửi thông báo đơn lẻ đến một thiết bị di động qua FCM Token.
     *
     * @param pushToken FCM Device Token
     * @param title     Tiêu đề thông báo
     * @param body      Nội dung thông báo (Myanmar Unicode / English)
     * @param data      Payload dữ liệu mở rộng
     * @return true nếu gửi thành công
     */
    boolean sendNotification(String pushToken, String title, String body, Map<String, String> data);

    /**
     * Gửi thông báo hàng loạt (Batch Dispatch) tối đa 500 tin/mẻ qua HTTP/2.
     *
     * @param messages Danh sách các thông điệp cần gửi
     * @return Số lượng thông báo gửi thành công
     */
    int sendBatchNotifications(List<PushNotificationMessage> messages);
}
