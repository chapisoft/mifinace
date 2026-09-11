import '../models/customer_loan.dart';
import '../models/customer_schedule_item.dart';

/// Repository interface managing borrower active loans and installment schedules.
abstract class CustomerLoanRepository {
  /// Fetches active loan contracts for a given member NRC.
  Future<List<CustomerLoan>> getActiveLoans(String memberNrc);

  /// Fetches full repayment schedule installments for a specific contract.
  Future<List<CustomerScheduleItem>> getLoanSchedule(String contractCode);
}
