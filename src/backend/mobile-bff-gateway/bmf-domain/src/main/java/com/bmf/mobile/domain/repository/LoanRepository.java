package com.bmf.mobile.domain.repository;

import com.bmf.mobile.domain.entity.GroupScheduleRecord;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Cổng giao tiếp truy xuất dữ liệu tín dụng, lịch nợ và Cụm/Tổ từ hệ thống Core NG-mFINA (Domain Repository).
 */
public interface LoanRepository {

    /**
     * Lấy danh sách lịch nợ đến hạn của toàn bộ thành viên trong Cụm/Tổ theo ngày.
     */
    List<GroupScheduleRecord> findSchedulesByGroupCodeAndDate(String groupCode, LocalDate dueDate);

    /**
     * Lấy toàn bộ lịch nợ của một hợp đồng vay vốn.
     */
    List<GroupScheduleRecord> findSchedulesByContractCode(String contractCode);

    /**
     * Lấy toàn bộ lịch nợ và hợp đồng của một khách hàng thành viên.
     */
    List<GroupScheduleRecord> findSchedulesByCustomerCode(String customerCode);

    /**
     * Tra cứu chi tiết một kỳ thu nợ cụ thể của hợp đồng.
     */
    Optional<GroupScheduleRecord> findScheduleByContractAndPeriod(String contractCode, int periodNumber);

    /**
     * Tra cứu danh sách các kỳ nợ đến hạn trong khoảng thời gian [fromDate, toDate].
     */
    List<GroupScheduleRecord> findSchedulesDueBetween(LocalDate fromDate, LocalDate toDate);

    /**
     * Cập nhật trạng thái và số tiền đã thu vào kỳ nợ trong CSDL Core.
     */
    void updateScheduleStatus(String contractCode, int periodNumber, String status, BigDecimal collectedAmount);
}
