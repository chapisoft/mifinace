import 'package:equatable/equatable.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/loan_type.dart';

/// Entity representing a borrower's active microfinance loan contract.
class CustomerLoan extends Equatable {
  final String loanId;
  final String contractCode;
  final String customerCode;
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
    required this.customerCode,
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
      'customerCode': customerCode,
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
    final cCode = (json['contractCode'] ?? json['loanId'] ?? json['maHopDong'] ?? '').toString();
    final custCode = (json['customerCode'] ?? json['borrowerCode'] ?? json['maThanhVien'] ?? '').toString();
    final lId = (json['loanId'] ?? json['contractCode'] ?? cCode).toString();

    final disbursed = (json['disbursedAmountMmk'] ?? json['loanAmount'] ?? json['disbursedAmount'] ?? json['soTienVay'] as num?)?.toDouble() ?? 1500000.0;
    final repaid = (json['totalRepaidMmk'] ?? json['totalRepaid'] as num?)?.toDouble() ?? 0.0;
    final remaining = (json['remainingPrincipalMmk'] ?? json['totalOutstandingPrincipal'] ?? json['outstandingAmount'] as num?)?.toDouble() ?? 350000.0;
    final rate = (json['interestRateAnnual'] ?? json['interestRate'] ?? json['laiSuatNam'] as num?)?.toDouble() ?? 28.0;

    final tPeriods = (json['totalPeriods'] ?? json['soKyVay'] as num?)?.toInt() ?? 12;
    final pPeriods = (json['paidPeriods'] ?? json['totalPeriodsPaid'] as num?)?.toInt() ?? 0;

    DateTime dDate = DateTime.now().subtract(const Duration(days: 150));
    final rawDisb = json['disbursedDate'] ?? json['ngayGiaiNgan'];
    if (rawDisb != null) {
      dDate = DateTime.tryParse(rawDisb.toString()) ?? dDate;
    }

    DateTime mDate = DateTime.now().add(const Duration(days: 210));
    final rawMat = json['maturityDate'] ?? json['ngayDaoHan'];
    if (rawMat != null) {
      mDate = DateTime.tryParse(rawMat.toString()) ?? mDate;
    }

    DateTime nextDue = DateTime.now();
    final rawNextDue = json['nextDueDate'] ?? json['ngayDenHan'];
    if (rawNextDue != null) {
      nextDue = DateTime.tryParse(rawNextDue.toString()) ?? nextDue;
    }

    final nextDueAmt = (json['nextDueAmountMmk'] ?? json['nextDueAmount'] as num?)?.toDouble() ?? 59250.0;
    final dueSoon = json['isDueSoon'] as bool? ?? true;

    return CustomerLoan(
      loanId: lId.isNotEmpty ? lId : 'HD-BMF-01',
      contractCode: cCode.isNotEmpty ? cCode : 'HD-BMF-01',
      customerCode: custCode,
      loanType: LoanType.fromCode(json['loanType'] as String?),
      disbursedAmountMmk: disbursed,
      totalRepaidMmk: repaid,
      remainingPrincipalMmk: remaining,
      interestRateAnnual: rate,
      disbursedDate: dDate,
      maturityDate: mDate,
      totalPeriods: tPeriods,
      paidPeriods: pPeriods,
      debtGroup: DebtGroup.fromCode(json['debtGroup'] as String?),
      nextDueDate: nextDue,
      nextDueAmountMmk: nextDueAmt,
      isDueSoon: dueSoon,
    );
  }

  @override
  List<Object?> get props => [
        loanId,
        contractCode,
        customerCode,
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
