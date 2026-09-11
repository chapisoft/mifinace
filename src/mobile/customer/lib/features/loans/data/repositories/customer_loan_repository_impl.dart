import '../../../core/enums/debt_group.dart';
import '../../../core/enums/loan_type.dart';
import '../../../core/enums/repayment_status.dart';
import '../../../core/utils/app_logger.dart';
import '../../domain/models/customer_loan.dart';
import '../../domain/models/customer_schedule_item.dart';
import '../../domain/repositories/customer_loan_repository.dart';

/// Implementation of [CustomerLoanRepository] querying Core Gateway with offline caching.
class CustomerLoanRepositoryImpl implements CustomerLoanRepository {
  final List<CustomerLoan> _cachedLoans = [];
  final Map<String, List<CustomerScheduleItem>> _cachedSchedules = {};

  CustomerLoanRepositoryImpl() {
    _initDemoCustomerLoans();
  }

  void _initDemoCustomerLoans() {
    final now = DateTime.now();
    final contractCode = 'BMF-GL-2025-0891';

    final loan = CustomerLoan(
      loanId: 'LN-2026-0012',
      contractCode: contractCode,
      loanType: LoanType.groupSolidarity,
      disbursedAmountMmk: 1500000.0,
      totalRepaidMmk: 875000.0,
      remainingPrincipalMmk: 625000.0,
      interestRateAnnual: 28.0,
      disbursedDate: now.subtract(const Duration(days: 210)),
      maturityDate: now.add(const Duration(days: 155)),
      totalPeriods: 12,
      paidPeriods: 7,
      debtGroup: DebtGroup.current,
      nextDueDate: now.add(const Duration(days: 2)),
      nextDueAmountMmk: 145000.0,
      isDueSoon: true, // Triggers prominent golden alert card
    );

    _cachedLoans.add(loan);

    // Build 12 Periods Schedule
    final schedules = <CustomerScheduleItem>[];
    for (int i = 1; i <= 12; i++) {
      final periodDueDate = now.subtract(Duration(days: (7 - i) * 30));
      RepaymentStatus status;
      DateTime? paidDate;

      if (i < 7) {
        status = RepaymentStatus.paid;
        paidDate = periodDueDate.subtract(const Duration(days: 1));
      } else if (i == 7) {
        status = RepaymentStatus.paid;
        paidDate = periodDueDate;
      } else if (i == 8) {
        status = RepaymentStatus.dueToday;
      } else {
        status = RepaymentStatus.upcoming;
      }

      schedules.add(
        CustomerScheduleItem(
          scheduleId: 'SCH-$contractCode-P${i.toString().padLeft(2, "0")}',
          periodNumber: i,
          dueDate: periodDueDate,
          principalDueMmk: 125000.0,
          interestDueMmk: 15000.0,
          insuranceFeeMmk: 2500.0,
          savingFeeMmk: 2500.0,
          totalDueMmk: 145000.0,
          status: status,
          paidDate: paidDate,
          overdueDays: 0,
          debtGroup: DebtGroup.current,
        ),
      );
    }

    _cachedSchedules[contractCode] = schedules;
  }

  @override
  Future<List<CustomerLoan>> getActiveLoans(String memberNrc) async {
    AppLogger.info('Retrieving active loans for member: $memberNrc', tag: 'LoanRepo');
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_cachedLoans);
  }

  @override
  Future<List<CustomerScheduleItem>> getLoanSchedule(String contractCode) async {
    AppLogger.info('Retrieving repayment schedule for contract: $contractCode', tag: 'LoanRepo');
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_cachedSchedules[contractCode] ?? []);
  }
}
