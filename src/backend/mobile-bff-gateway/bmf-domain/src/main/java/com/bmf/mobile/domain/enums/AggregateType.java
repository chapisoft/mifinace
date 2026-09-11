package com.bmf.mobile.domain.enums;

/**
 * Phân loại gốc nghiệp vụ (Aggregate Root) trong hệ thống Outbox Pattern.
 */
public enum AggregateType {
    /**
     * Nghiệp vụ Tín dụng / Hợp đồng vay vốn (TD_KHOANVAY, TD_GIAINGAN, TD_THUNO).
     */
    LOAN,

    /**
     * Nghiệp vụ Tiết kiệm (TK_SO_TIETKIEM, TK_SOGD).
     */
    SAVING,

    /**
     * Nghiệp vụ Khách hàng thành viên (KH_THANHVIEN).
     */
    CUSTOMER,

    /**
     * Nghiệp vụ Bảo hiểm / Quỹ tương trợ thành viên (BH_QUY_TUONGTRO).
     */
    INSURANCE
}
