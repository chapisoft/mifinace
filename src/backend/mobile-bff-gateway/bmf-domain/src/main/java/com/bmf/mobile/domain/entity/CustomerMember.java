package com.bmf.mobile.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho Khách hàng thành viên vay vốn (Customer) trong bảng KH_THANHVIEN.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "pinHash")
public class CustomerMember {

    private String customerCode;
    private String fullName;
    private String nrcNumber;
    private String phoneNumber;
    private String pinHash;
    private String groupCode;
    private String centerCode;
    private String township;
    private boolean active;
    private LocalDateTime createdTime;
}
