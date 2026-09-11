import 'package:equatable/equatable.dart';

enum SavingType {
  compulsory(code: 'COMPULSORY', label: 'Compulsory Group Savings', interestRatePercent: 8.0),
  voluntary(code: 'VOLUNTARY', label: 'Voluntary Demand Deposit', interestRatePercent: 10.0),
  fixedTerm(code: 'FIXED_TERM', label: 'High-Yield Fixed Term', interestRatePercent: 14.0);

  final String code;
  final String label;
  final double interestRatePercent;

  const SavingType({
    required this.code,
    required this.label,
    required this.interestRatePercent,
  });

  static SavingType fromCode(String? code) {
    if (code == null) return SavingType.compulsory;
    for (final t in SavingType.values) {
      if (t.code == code || t.name.toUpperCase() == code.toUpperCase()) {
        return t;
      }
    }
    return SavingType.compulsory;
  }
}

/// Entity representing a customer savings passbook account.
class CustomerSavingAccount extends Equatable {
  final String accountId;
  final String accountNumber;
  final SavingType savingType;
  final double balanceMmk;
  final double accruedInterestMmk;
  final double interestRateAnnual;
  final DateTime openedDate;
  final DateTime? maturityDate;
  final int tenureMonths;

  const CustomerSavingAccount({
    required this.accountId,
    required this.accountNumber,
    required this.savingType,
    required this.balanceMmk,
    required this.accruedInterestMmk,
    required this.interestRateAnnual,
    required this.openedDate,
    this.maturityDate,
    required this.tenureMonths,
  });

  double get totalProjectedMmk => balanceMmk + accruedInterestMmk;

  @override
  List<Object?> get props => [
        accountId,
        accountNumber,
        savingType,
        balanceMmk,
        accruedInterestMmk,
        interestRateAnnual,
        openedDate,
        maturityDate,
        tenureMonths,
      ];
}
