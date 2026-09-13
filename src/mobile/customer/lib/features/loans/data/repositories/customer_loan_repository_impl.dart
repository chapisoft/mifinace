import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/loan_type.dart';
import '../../../../core/enums/repayment_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/customer_loan.dart';
import '../../domain/models/customer_schedule_item.dart';
import '../../domain/repositories/customer_loan_repository.dart';

/// Implementation of [CustomerLoanRepository] querying Core Gateway with offline caching.
class CustomerLoanRepositoryImpl implements CustomerLoanRepository {
  final ApiClient _apiClient;
  final List<CustomerLoan> _cachedLoans = [];
  final Map<String, List<CustomerScheduleItem>> _cachedSchedules = {};

  CustomerLoanRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(secureStorage: SecureStorageService());

  @override
  Future<List<CustomerLoan>> getActiveLoans(String memberNrc) async {
    AppLogger.info('Retrieving active loans for member: $memberNrc', tag: 'LoanRepo');

    try {
      final response = await _apiClient.get(ApiEndpoints.getMyLoans);
      if (response.statusCode == 200 && response.data != null) {
        final dynamic body = response.data;
        List<dynamic> list = [];
        if (body is Map<String, dynamic>) {
          final data = body['data'];
          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic>) {
            // Case CustomerLoanSummaryResponse
            if (data['schedules'] is List) {
              final schedList = (data['schedules'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((item) => CustomerScheduleItem.fromJson(item))
                  .toList();
              if (schedList.isNotEmpty) {
                final contractCode = data['schedules'][0]['contractCode']?.toString() ?? 'HD-2026-2150001';
                _cachedSchedules[contractCode] = schedList;

                final nextDueSched = schedList.firstWhere(
                  (s) => s.status == RepaymentStatus.dueToday || s.status == RepaymentStatus.upcoming || s.status == RepaymentStatus.overdue,
                  orElse: () => schedList.last,
                );

                final summaryLoan = CustomerLoan(
                  loanId: contractCode,
                  contractCode: contractCode,
                  customerCode: data['customerCode']?.toString() ?? memberNrc,
                  loanType: LoanType.groupSolidarity,
                  disbursedAmountMmk: 1500000.0,
                  totalRepaidMmk: (data['totalPeriodsPaid'] as num? ?? 0).toDouble() * 50000.0,
                  remainingPrincipalMmk: (data['totalOutstandingPrincipal'] as num?)?.toDouble() ?? 350000.0,
                  interestRateAnnual: 28.0,
                  disbursedDate: DateTime.now().subtract(const Duration(days: 150)),
                  maturityDate: DateTime.now().add(const Duration(days: 210)),
                  totalPeriods: schedList.length,
                  paidPeriods: (data['totalPeriodsPaid'] as num?)?.toInt() ?? 0,
                  debtGroup: DebtGroup.current,
                  nextDueDate: nextDueSched.dueDate,
                  nextDueAmountMmk: nextDueSched.totalDueMmk,
                  isDueSoon: true,
                );

                _cachedLoans.clear();
                _cachedLoans.add(summaryLoan);
                return List.unmodifiable(_cachedLoans);
              }
            }
          }
        } else if (body is List) {
          list = body;
        }

        if (list.isNotEmpty) {
          final loans = list
              .whereType<Map<String, dynamic>>()
              .map((item) => CustomerLoan.fromJson(item))
              .toList();
          _cachedLoans.clear();
          _cachedLoans.addAll(loans);
          return List.unmodifiable(_cachedLoans);
        }
      }
    } catch (e) {
      AppLogger.warn('Failed to fetch active loans from Gateway: $e. Returning cached records.', tag: 'LoanRepo');
    }

    return List.unmodifiable(_cachedLoans);
  }

  @override
  Future<List<CustomerScheduleItem>> getLoanSchedule(String contractCode) async {
    AppLogger.info('Retrieving repayment schedule for contract: $contractCode', tag: 'LoanRepo');

    if (_cachedSchedules.containsKey(contractCode) && _cachedSchedules[contractCode]!.isNotEmpty) {
      return List.unmodifiable(_cachedSchedules[contractCode]!);
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.getLoanSchedule(contractCode));
      if (response.statusCode == 200 && response.data != null) {
        final dynamic body = response.data;
        List<dynamic> list = [];
        if (body is Map<String, dynamic>) {
          if (body['data'] is List) {
            list = body['data'] as List<dynamic>;
          } else if (body['data'] is Map && body['data']['schedules'] is List) {
            list = body['data']['schedules'] as List<dynamic>;
          }
        } else if (body is List) {
          list = body;
        }

        final schedules = list
            .whereType<Map<String, dynamic>>()
            .map((item) => CustomerScheduleItem.fromJson(item))
            .toList();
        if (schedules.isNotEmpty) {
          _cachedSchedules[contractCode] = schedules;
          return List.unmodifiable(schedules);
        }
      }
    } catch (e) {
      AppLogger.warn('Failed to fetch loan schedule from Gateway: $e. Returning cached records.', tag: 'LoanRepo');
    }

    return List.unmodifiable(_cachedSchedules[contractCode] ?? []);
  }
}
