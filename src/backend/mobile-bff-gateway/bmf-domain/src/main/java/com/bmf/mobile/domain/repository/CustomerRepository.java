package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.CustomerMember;

import java.util.Optional;

/**
 * Cổng giao tiếp truy xuất dữ liệu thành viên vay vốn (Khách hàng).
 */
public interface CustomerRepository {

    /**
     * Tìm kiếm thành viên theo số thẻ căn cước NRC Myanmar.
     */
    Optional<CustomerMember> findByNrcNumber(String nrcNumber);

    /**
     * Tìm kiếm thành viên theo mã khách hàng (CustomerCode).
     */
    Optional<CustomerMember> findByCustomerCode(String customerCode);

    /**
     * Cập nhật mã PIN mới đã băm cho khách hàng.
     */
    void updatePinHash(String customerCode, String newPinHash);
}
