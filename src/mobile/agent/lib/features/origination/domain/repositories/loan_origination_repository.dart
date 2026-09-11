import '../models/loan_application.dart';

/// Repository interface for creating, validating, and submitting field loan origination applications.
abstract class LoanOriginationRepository {
  /// Submits and saves a loan application into local encrypted storage and the sync queue.
  Future<LoanApplication> submitLoanApplication(LoanApplication application);

  /// Retrieves cached draft applications from local database.
  Future<List<LoanApplication>> getPendingApplications();
}
