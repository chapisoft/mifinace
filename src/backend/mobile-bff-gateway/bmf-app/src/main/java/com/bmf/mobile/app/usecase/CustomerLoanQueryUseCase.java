package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.response.CustomerLoanSummaryResponse;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.entity.GroupScheduleRecord;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.repository.CustomerRepository;
import com.bmf.mobile.domain.repository.LoanRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

/**
 * UseCase tra cứu hợp đồng tín dụng và lịch nợ của Khách hàng thành viên (ROLE_CUSTOMER).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerLoanQueryUseCase {

    private final LoanRepository loanRepository;
    private final CustomerRepository customerRepository;

    public CustomerLoanSummaryResponse getLoanSummary(String customerCode) {
        log.info("Processing customer loan query: customerCode={}", customerCode);

        CustomerMember customer = customerRepository.findByCustomerCode(customerCode)
                .orElseThrow(() -> {
                    log.warn("Customer loan query failed - customer not found: {}", customerCode);
                    return new BusinessException(ErrorCode.ERR_USER_NOT_FOUND);
                });

        List<GroupScheduleRecord> schedules = loanRepository.findSchedulesByCustomerCode(customerCode);

        BigDecimal totalOutstandingPrincipal = schedules.stream()
                .filter(s -> !RepaymentStatus.SETTLED.name().equalsIgnoreCase(s.getStatus()))
                .map(s -> s.getPrincipalAmount() != null ? s.getPrincipalAmount() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int totalPeriodsPaid = (int) schedules.stream()
                .filter(s -> RepaymentStatus.SETTLED.name().equalsIgnoreCase(s.getStatus()))
                .count();

        int totalPeriodsRemaining = schedules.size() - totalPeriodsPaid;

        log.info("Customer loan query completed: customerCode={}, totalSchedules={}, outstanding={}",
                customerCode, schedules.size(), totalOutstandingPrincipal);

        return CustomerLoanSummaryResponse.builder()
                .customerCode(customer.getCustomerCode())
                .fullName(customer.getFullName())
                .groupCode(customer.getGroupCode())
                .totalOutstandingPrincipal(totalOutstandingPrincipal)
                .totalPeriodsPaid(totalPeriodsPaid)
                .totalPeriodsRemaining(totalPeriodsRemaining)
                .schedules(schedules)
                .build();
    }

    public com.bmf.mobile.app.dto.response.CustomerLoanScheduleResponse getLoanScheduleDetail(String customerCode, String loanCode) {
        log.info("Processing customer loan schedule detail: customerCode={}, loanCode={}", customerCode, loanCode);

        CustomerMember customer = customerRepository.findByCustomerCode(customerCode)
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_USER_NOT_FOUND));

        List<GroupScheduleRecord> records = loanRepository.findSchedulesByContractCode(loanCode);
        if (records.isEmpty()) {
            throw new BusinessException(ErrorCode.ERR_LOAN_NOT_FOUND);
        }

        BigDecimal totalPrincipal = BigDecimal.ZERO;
        BigDecimal remainingPrincipal = BigDecimal.ZERO;
        int paidCount = 0;
        int maxOverdueDays = 0;
        java.time.LocalDate today = java.time.LocalDate.now();

        List<com.bmf.mobile.app.dto.response.CustomerLoanScheduleItemResponse> items = new java.util.ArrayList<>();

        for (GroupScheduleRecord record : records) {
            BigDecimal principal = record.getPrincipalAmount() != null ? record.getPrincipalAmount() : BigDecimal.ZERO;
            totalPrincipal = totalPrincipal.add(principal);

            boolean isSettled = RepaymentStatus.SETTLED.name().equalsIgnoreCase(record.getStatus());
            if (isSettled) {
                paidCount++;
            } else {
                remainingPrincipal = remainingPrincipal.add(principal);
            }

            int overdueDays = 0;
            if (!isSettled && record.getDueDate() != null && today.isAfter(record.getDueDate())) {
                overdueDays = (int) java.time.temporal.ChronoUnit.DAYS.between(record.getDueDate(), today);
                if (overdueDays > maxOverdueDays) {
                    maxOverdueDays = overdueDays;
                }
            }

            com.bmf.mobile.domain.enums.DebtClassificationGroup group = com.bmf.mobile.domain.enums.DebtClassificationGroup.fromOverdueDays(overdueDays);

            items.add(com.bmf.mobile.app.dto.response.CustomerLoanScheduleItemResponse.builder()
                    .scheduleId((long) record.getPeriodNumber())
                    .installmentNo(record.getPeriodNumber())
                    .dueDate(record.getDueDate())
                    .principalAmount(record.getPrincipalAmount())
                    .interestAmount(record.getInterestAmount())
                    .compulsorySavingAmount(record.getCompulsorySaving())
                    .insuranceFee(record.getInsuranceFee())
                    .totalDueAmount(record.getTotalAmount())
                    .paidAmount(isSettled ? record.getTotalAmount() : BigDecimal.ZERO)
                    .status(record.getStatus())
                    .overdueDays(overdueDays)
                    .debtGroup(group.name())
                    .debtGroupDescription(group.getDescription())
                    .build());
        }

        com.bmf.mobile.domain.enums.DebtClassificationGroup overallGroup = com.bmf.mobile.domain.enums.DebtClassificationGroup.fromOverdueDays(maxOverdueDays);

        log.info("Calculated FRD debt classification: loanCode={}, maxOverdueDays={}, group={}",
                loanCode, maxOverdueDays, overallGroup.name());

        return com.bmf.mobile.app.dto.response.CustomerLoanScheduleResponse.builder()
                .loanCode(loanCode)
                .customerCode(customer.getCustomerCode())
                .customerName(customer.getFullName())
                .totalPrincipal(totalPrincipal)
                .remainingPrincipal(remainingPrincipal)
                .totalInstallments(records.size())
                .paidInstallments(paidCount)
                .maxOverdueDays(maxOverdueDays)
                .currentDebtGroup(overallGroup.name())
                .currentDebtGroupDescription(overallGroup.getDescription())
                .schedules(items)
                .build();
    }
}
