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

  factory CustomerSavingAccount.fromJson(Map<String, dynamic> json) {
    return CustomerSavingAccount(
      accountId: json['accountId']?.toString() ?? json['id']?.toString() ?? json['accountNumber']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      savingType: SavingType.fromCode(json['productType']?.toString() ?? json['savingType']?.toString()),
      balanceMmk: (json['balanceMmk'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          (json['currentBalance'] as num?)?.toDouble() ??
          0.0,
      accruedInterestMmk: (json['accruedInterestMmk'] as num?)?.toDouble() ??
          (json['accruedInterest'] as num?)?.toDouble() ??
          0.0,
      interestRateAnnual: (json['interestRateAnnual'] as num?)?.toDouble() ??
          (json['interestRate'] as num?)?.toDouble() ??
          8.0,
      openedDate: json['openedDate'] != null
          ? DateTime.tryParse(json['openedDate'].toString()) ?? DateTime.now()
          : (json['createdTime'] != null ? DateTime.tryParse(json['createdTime'].toString()) ?? DateTime.now() : DateTime.now()),
      maturityDate: json['maturityDate'] != null ? DateTime.tryParse(json['maturityDate'].toString()) : null,
      tenureMonths: (json['tenureMonths'] as num?)?.toInt() ?? (json['termMonths'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountNumber': accountNumber,
      'savingType': savingType.code,
      'balanceMmk': balanceMmk,
      'accruedInterestMmk': accruedInterestMmk,
      'interestRateAnnual': interestRateAnnual,
      'openedDate': openedDate.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'tenureMonths': tenureMonths,
    };
  }

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
