import '../models/saving_account.dart';
import '../models/saving_deposit.dart';

/// Repository interface for village savings accounts and field deposits.
abstract class SavingRepository {
  /// Fetches savings accounts filtered by centerCode or search query.
  Future<List<SavingAccount>> getSavingAccounts({String? centerCode, String? query});

  /// Deposits cash into a savings account, recording locally and queuing for sync.
  Future<SavingDeposit> depositSaving(SavingDeposit deposit);

  /// Opens a new savings account for a borrower in the field.
  Future<SavingAccount> openSavingAccount(SavingAccount account, {double initialDepositMmk = 0.0});
}
