package com.bmf.mobile.domain.port;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

/**
 * Thông tin phiên làm việc gắn với Refresh Token lưu trong Distributed Cache (Redis).
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefreshTokenData implements Serializable {
    private static final long serialVersionUID = 1L;

    private String userId;
    private String userType;
    private String deviceId;
    private String platform;
}
