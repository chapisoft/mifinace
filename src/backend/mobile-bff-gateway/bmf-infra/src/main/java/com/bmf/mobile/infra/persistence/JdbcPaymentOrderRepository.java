package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.PaymentOrder;
import com.bmf.mobile.domain.enums.PaymentOrderStatus;
import com.bmf.mobile.domain.enums.PaymentProvider;
import com.bmf.mobile.domain.repository.PaymentOrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Triển khai JDBC truy vấn bảng SYS_PAYMENT_ORDER trên SQL Server.
 */
@Slf4j
@Repository
@RequiredArgsConstructor
public class JdbcPaymentOrderRepository implements PaymentOrderRepository {

    private final JdbcClient jdbcClient;
    private final Map<String, PaymentOrder> memoryStore = new ConcurrentHashMap<>();

    @Override
    public void save(PaymentOrder order) {
        memoryStore.put(order.getOrderNo(), order);
        try {
            String sql = """
                INSERT INTO dbo.SYS_PAYMENT_ORDER (
                    Order_No, Loan_Code, Schedule_Id, Amount, Currency, Provider, Status,
                    Mmqr_Payload, Partner_Ref_No, Expired_Time, Created_Time, Updated_Time, Settled_Time
                ) VALUES (
                    :orderNo, :loanCode, :scheduleId, :amount, :currency, :provider, :status,
                    :mmqrPayload, :partnerRefNo, :expiredTime, :createdTime, :updatedTime, :settledTime
                )
                """;

            jdbcClient.sql(sql)
                    .param("orderNo", order.getOrderNo())
                    .param("loanCode", order.getLoanCode())
                    .param("scheduleId", order.getScheduleId())
                    .param("amount", order.getAmount())
                    .param("currency", order.getCurrency())
                    .param("provider", order.getProvider().name())
                    .param("status", order.getStatus().name())
                    .param("mmqrPayload", order.getMmqrPayload())
                    .param("partnerRefNo", order.getPartnerRefNo())
                    .param("expiredTime", Timestamp.valueOf(order.getExpiredTime()))
                    .param("createdTime", Timestamp.valueOf(order.getCreatedTime()))
                    .param("updatedTime", Timestamp.valueOf(order.getUpdatedTime()))
                    .param("settledTime", order.getSettledTime() != null ? Timestamp.valueOf(order.getSettledTime()) : null)
                    .update();
            log.info("Saved payment order to database: orderNo={}", order.getOrderNo());
        } catch (Exception e) {
            log.warn("Database insert failed for payment order (using memory store fallback): orderNo={}, error={}",
                    order.getOrderNo(), e.getMessage());
        }
    }

    @Override
    public Optional<PaymentOrder> findByOrderNo(String orderNo) {
        try {
            String sql = """
                SELECT Id, Order_No, Loan_Code, Schedule_Id, Amount, Currency, Provider, Status,
                       Mmqr_Payload, Partner_Ref_No, Expired_Time, Created_Time, Updated_Time, Settled_Time
                FROM dbo.SYS_PAYMENT_ORDER
                WHERE Order_No = :orderNo
                """;

            return jdbcClient.sql(sql)
                    .param("orderNo", orderNo)
                    .query((rs, rowNum) -> PaymentOrder.builder()
                            .id(rs.getLong("Id"))
                            .orderNo(rs.getString("Order_No"))
                            .loanCode(rs.getString("Loan_Code"))
                            .scheduleId(rs.getLong("Schedule_Id"))
                            .amount(rs.getBigDecimal("Amount"))
                            .currency(rs.getString("Currency"))
                            .provider(PaymentProvider.valueOf(rs.getString("Provider")))
                            .status(PaymentOrderStatus.valueOf(rs.getString("Status")))
                            .mmqrPayload(rs.getString("Mmqr_Payload"))
                            .partnerRefNo(rs.getString("Partner_Ref_No"))
                            .expiredTime(rs.getTimestamp("Expired_Time").toLocalDateTime())
                            .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                            .updatedTime(rs.getTimestamp("Updated_Time").toLocalDateTime())
                            .settledTime(rs.getTimestamp("Settled_Time") != null ? rs.getTimestamp("Settled_Time").toLocalDateTime() : null)
                            .build())
                    .optional();
        } catch (Exception e) {
            log.warn("Database query failed for payment order (using memory store fallback): orderNo={}", orderNo);
            return Optional.ofNullable(memoryStore.get(orderNo));
        }
    }

    @Override
    public Optional<PaymentOrder> findByLoanCodeAndScheduleId(String loanCode, Long scheduleId) {
        try {
            String sql = """
                SELECT Id, Order_No, Loan_Code, Schedule_Id, Amount, Currency, Provider, Status,
                       Mmqr_Payload, Partner_Ref_No, Expired_Time, Created_Time, Updated_Time, Settled_Time
                FROM dbo.SYS_PAYMENT_ORDER
                WHERE Loan_Code = :loanCode AND Schedule_Id = :scheduleId AND Status = 'PENDING'
                """;

            return jdbcClient.sql(sql)
                    .param("loanCode", loanCode)
                    .param("scheduleId", scheduleId)
                    .query((rs, rowNum) -> PaymentOrder.builder()
                            .id(rs.getLong("Id"))
                            .orderNo(rs.getString("Order_No"))
                            .loanCode(rs.getString("Loan_Code"))
                            .scheduleId(rs.getLong("Schedule_Id"))
                            .amount(rs.getBigDecimal("Amount"))
                            .currency(rs.getString("Currency"))
                            .provider(PaymentProvider.valueOf(rs.getString("Provider")))
                            .status(PaymentOrderStatus.valueOf(rs.getString("Status")))
                            .mmqrPayload(rs.getString("Mmqr_Payload"))
                            .partnerRefNo(rs.getString("Partner_Ref_No"))
                            .expiredTime(rs.getTimestamp("Expired_Time").toLocalDateTime())
                            .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                            .updatedTime(rs.getTimestamp("Updated_Time").toLocalDateTime())
                            .settledTime(rs.getTimestamp("Settled_Time") != null ? rs.getTimestamp("Settled_Time").toLocalDateTime() : null)
                            .build())
                    .optional();
        } catch (Exception e) {
            return memoryStore.values().stream()
                    .filter(o -> o.getLoanCode().equals(loanCode) && o.getScheduleId().equals(scheduleId) && o.getStatus() == PaymentOrderStatus.PENDING)
                    .findFirst();
        }
    }

    @Override
    public void updateStatus(String orderNo, PaymentOrderStatus status, String partnerRefNo, LocalDateTime settledTime) {
        PaymentOrder memOrder = memoryStore.get(orderNo);
        if (memOrder != null) {
            memOrder.setStatus(status);
            memOrder.setPartnerRefNo(partnerRefNo);
            memOrder.setSettledTime(settledTime);
            memOrder.setUpdatedTime(LocalDateTime.now());
        }

        try {
            String sql = """
                UPDATE dbo.SYS_PAYMENT_ORDER
                SET Status = :status,
                    Partner_Ref_No = :partnerRefNo,
                    Settled_Time = :settledTime,
                    Updated_Time = :updatedTime
                WHERE Order_No = :orderNo
                """;

            jdbcClient.sql(sql)
                    .param("status", status.name())
                    .param("partnerRefNo", partnerRefNo)
                    .param("settledTime", settledTime != null ? Timestamp.valueOf(settledTime) : null)
                    .param("updatedTime", Timestamp.valueOf(LocalDateTime.now()))
                    .param("orderNo", orderNo)
                    .update();
            log.info("Updated payment order status: orderNo={}, status={}", orderNo, status);
        } catch (Exception e) {
            log.warn("Database update failed for payment order (using memory store fallback): orderNo={}, status={}", orderNo, status);
        }
    }

    @Override
    public List<PaymentOrder> findPendingOrdersByLoanCode(String loanCode) {
        try {
            String sql = """
                SELECT Id, Order_No, Loan_Code, Schedule_Id, Amount, Currency, Provider, Status,
                       Mmqr_Payload, Partner_Ref_No, Expired_Time, Created_Time, Updated_Time, Settled_Time
                FROM dbo.SYS_PAYMENT_ORDER
                WHERE Loan_Code = :loanCode AND Status = 'PENDING'
                """;

            return jdbcClient.sql(sql)
                    .param("loanCode", loanCode)
                    .query((rs, rowNum) -> PaymentOrder.builder()
                            .id(rs.getLong("Id"))
                            .orderNo(rs.getString("Order_No"))
                            .loanCode(rs.getString("Loan_Code"))
                            .scheduleId(rs.getLong("Schedule_Id"))
                            .amount(rs.getBigDecimal("Amount"))
                            .currency(rs.getString("Currency"))
                            .provider(PaymentProvider.valueOf(rs.getString("Provider")))
                            .status(PaymentOrderStatus.valueOf(rs.getString("Status")))
                            .mmqrPayload(rs.getString("Mmqr_Payload"))
                            .partnerRefNo(rs.getString("Partner_Ref_No"))
                            .expiredTime(rs.getTimestamp("Expired_Time").toLocalDateTime())
                            .createdTime(rs.getTimestamp("Created_Time").toLocalDateTime())
                            .updatedTime(rs.getTimestamp("Updated_Time").toLocalDateTime())
                            .settledTime(rs.getTimestamp("Settled_Time") != null ? rs.getTimestamp("Settled_Time").toLocalDateTime() : null)
                            .build())
                    .list();
        } catch (Exception e) {
            return memoryStore.values().stream()
                    .filter(o -> o.getLoanCode().equals(loanCode) && o.getStatus() == PaymentOrderStatus.PENDING)
                    .toList();
        }
    }
}
