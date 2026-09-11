import 'package:bmf_customer/core/utils/app_logger.dart';
import '../../domain/models/customer_saving_account.dart';
import '../../domain/repositories/savings_repository.dart';

/// Implementation of [SavingsRepository] querying Core Saving Gateway.
class SavingsRepositoryImpl implements SavingsRepository {
  final List<CustomerSavingAccount> _accounts = [];

  SavingsRepositoryImpl() {
    _initDemoSavings();
  }

  void _initDemoSavings() {
    _accounts.addAll([
      CustomerSavingAccount(
        accountId: 'SAV-001',
        accountNumber: 'BMF-SAV-098231',
        savingType: SavingType.compulsory,
        balanceMmk: 120000.0,
        accruedInterestMmk: 4800.0,
        interestRateAnnual: 8.0,
        openedDate: DateTime(2025, 6, 1),
        tenureMonths: 12,
      ),
      CustomerSavingAccount(
        accountId: 'SAV-002',
        accountNumber: 'BMF-SAV-114920',
        savingType: SavingType.voluntary,
        balanceMmk: 250000.0,
        accruedInterestMmk: 12500.0,
        interestRateAnnual: 10.0,
        openedDate: DateTime(2025, 9, 15),
        tenureMonths: 0,
      ),
    ]);
  }

  @override
  Future<List<CustomerSavingAccount>> getSavingAccounts(String memberNrc) async {
    AppLogger.info('Retrieving savings accounts for member: $memberNrc', tag: 'SavingsRepo');
    return List.unmodifiable(_accounts);
  }

  @override
  Future<CustomerSavingAccount> openFixedTermSaving({
    required String memberNrc,
    required double initialDepositMmk,
    required int tenureMonths,
    required String beneficiaryName,
  }) async {
    AppLogger.info('Opening new $tenureMonths-month fixed savings for $memberNrc, beneficiary: $beneficiaryName', tag: 'SavingsRepo');

    final now = DateTime.now();
    final maturity = now.add(Duration(days: tenureMonths * 30));
    final newAccount = CustomerSavingAccount(
      accountId: 'SAV-${now.millisecondsSinceEpoch}',
      accountNumber: 'BMF-FIX-${now.millisecondsSinceEpoch.toString().substring(7)}',
      savingType: SavingType.fixedTerm,
      balanceMmk: initialDepositMmk,
      accruedInterestMmk: 0.0,
      interestRateAnnual: 14.0,
      openedDate: now,
      maturityDate: maturity,
      tenureMonths: tenureMonths,
    );

    _accounts.add(newAccount);
    return newAccount;
  }
}
