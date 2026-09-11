import '../models/customer_saving_account.dart';

/// Repository interface managing borrower savings passbooks and term deposit subscriptions.
abstract class SavingsRepository {
  /// Fetches all active savings accounts and daily accrued interest for the borrower.
  Future<List<CustomerSavingAccount>> getSavingAccounts(String memberNrc);

  /// Subscribes to a new fixed-term high-yield savings plan online.
  Future<CustomerSavingAccount> openFixedTermSaving({
    required String memberNrc,
    required double initialDepositMmk,
    required int tenureMonths,
    required String beneficiaryName,
  });
}
