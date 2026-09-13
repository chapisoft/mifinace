package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.CustomerMember;

import java.util.Optional;

/**
 * Cổng giao tiếp truy xuất dữ liệu thành viên vay vốn (Khách hàng) và Trưởng nhóm / Trưởng cụm (Agent).
 */
public interface CustomerRepository {

    /**
     * Tìm kiếm thành viên theo số thẻ căn cước NRC Myanmar.
     */
    Optional<CustomerMember> findByNrcNumber(String nrcNumber);

    /**
     * Tìm kiếm thành viên theo mã khách hàng (CustomerCode / Ma_ThanhVien).
     */
    Optional<CustomerMember> findByCustomerCode(String customerCode);

    /**
     * Tìm kiếm thành viên theo số điện thoại đăng ký.
     */
    Optional<CustomerMember> findByPhoneNumber(String phoneNumber);

    /**
     * Cập nhật mã PIN mới đã băm cho khách hàng.
     */
    void updatePinHash(String customerCode, String newPinHash);

    /**
     * Kiểm tra xem khách hàng có được phân công làm Trưởng nhóm hoặc Trưởng cụm (Agent) hay không.
     */
    boolean isGroupOrCenterLeader(String customerCode, String fullName, String groupCode, String centerCode);
}
