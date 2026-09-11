package com.bmf.mobile.domain.entity;

import com.bmf.mobile.domain.enums.UserType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho tài khoản Cán bộ tín dụng (Loan Officer / Agent) trong bảng HT_NGUOIDUNG.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "passwordHash")
public class SysUser {

    private String userId;
    private String username;
    private String fullName;
    private String passwordHash;
    private String branchCode;
    private String email;
    private String phoneNumber;
    private boolean active;
    private UserType userType;
    private LocalDateTime createdTime;
}
