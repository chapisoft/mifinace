import 'package:equatable/equatable.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/loan_type.dart';

/// Entity representing a borrower's active microfinance loan contract.
class CustomerLoan extends Equatable {
  final String loanId;
  final String contractCode;
  final LoanType loanType;
  final double disbursedAmountMmk;
  final double totalRepaidMmk;
  final double remainingPrincipalMmk;
  final double interestRateAnnual;
  final DateTime disbursedDate;
  final DateTime maturityDate;
  final int totalPeriods;
  final int paidPeriods;
  final DebtGroup debtGroup;
  final DateTime nextDueDate;
  final double nextDueAmountMmk;
  final bool isDueSoon;

  const CustomerLoan({
    required this.loanId,
    required this.contractCode,
    required this.loanType,
    required this.disbursedAmountMmk,
    required this.totalRepaidMmk,
    required this.remainingPrincipalMmk,
    required this.interestRateAnnual,
    required this.disbursedDate,
    required this.maturityDate,
    required this.totalPeriods,
    required this.paidPeriods,
    required this.debtGroup,
    required this.nextDueDate,
    required this.nextDueAmountMmk,
    required this.isDueSoon,
  });

  double get completionProgress => totalPeriods > 0 ? paidPeriods / totalPeriods : 0.0;
  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() {
    return {
      'loanId': loanId,
      'contractCode': contractCode,
      'loanType': loanType.code,
      'disbursedAmountMmk': disbursedAmountMmk,
      'totalRepaidMmk': totalRepaidMmk,
      'remainingPrincipalMmk': remainingPrincipalMmk,
      'interestRateAnnual': interestRateAnnual,
      'disbursedDate': disbursedDate.toIso8601String(),
      'maturityDate': maturityDate.toIso8601String(),
      'totalPeriods': totalPeriods,
      'paidPeriods': paidPeriods,
      'debtGroup': debtGroup.code,
      'nextDueDate': nextDueDate.toIso8601String(),
      'nextDueAmountMmk': nextDueAmountMmk,
      'isDueSoon': isDueSoon,
    };
  }

  factory CustomerLoan.fromJson(Map<String, dynamic> json) {
    return CustomerLoan(
      loanId: json['loanId'] as String,
      contractCode: json['contractCode'] as String,
      loanType: LoanType.fromCode(json['loanType'] as String?),
      disbursedAmountMmk: (json['disbursedAmountMmk'] as num).toDouble(),
      totalRepaidMmk: (json['totalRepaidMmk'] as num).toDouble(),
      remainingPrincipalMmk: (json['remainingPrincipalMmk'] as num).toDouble(),
      interestRateAnnual: (json['interestRateAnnual'] as num).toDouble(),
      disbursedDate: DateTime.parse(json['disbursedDate'] as String),
      maturityDate: DateTime.parse(json['maturityDate'] as String),
      totalPeriods: json['totalPeriods'] as int,
      paidPeriods: json['paidPeriods'] as int,
      debtGroup: DebtGroup.fromCode(json['debtGroup'] as String?),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      nextDueAmountMmk: (json['nextDueAmountMmk'] as num).toDouble(),
      isDueSoon: json['isDueSoon'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        loanId,
        contractCode,
        loanType,
        disbursedAmountMmk,
        totalRepaidMmk,
        remainingPrincipalMmk,
        interestRateAnnual,
        disbursedDate,
        maturityDate,
        totalPeriods,
        paidPeriods,
        debtGroup,
        nextDueDate,
        nextDueAmountMmk,
        isDueSoon,
      ];
}
