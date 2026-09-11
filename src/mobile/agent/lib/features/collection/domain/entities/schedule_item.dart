import 'package:equatable/equatable.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/repayment_status.dart';

/// Entity representing a Loan Repayment Schedule item in the collection sheet.
class ScheduleItem extends Equatable {
  final String scheduleId;
  final String contractCode;
  final String customerCode;
  final String customerName;
  final String groupCode;
  final int periodNumber;
  final double principalAmount;
  final double interestAmount;
  final double insuranceFee;
  final double compulsorySaving;
  final double totalAmount;
  final DateTime dueDate;
  final RepaymentStatus status;
  final DebtGroup debtGroup;
  final double? collectedAmount;
  final DateTime? collectedAt;

  const ScheduleItem({
    required this.scheduleId,
    required this.contractCode,
    required this.customerCode,
    required this.customerName,
    required this.groupCode,
    required this.periodNumber,
    required this.principalAmount,
    required this.interestAmount,
    required this.insuranceFee,
    required this.compulsorySaving,
    required this.totalAmount,
    required this.dueDate,
    required this.status,
    required this.debtGroup,
    this.collectedAmount,
    this.collectedAt,
  });

  ScheduleItem copyWith({
    RepaymentStatus? status,
    double? collectedAmount,
    DateTime? collectedAt,
  }) {
    return ScheduleItem(
      scheduleId: scheduleId,
      contractCode: contractCode,
      customerCode: customerCode,
      customerName: customerName,
      groupCode: groupCode,
      periodNumber: periodNumber,
      principalAmount: principalAmount,
      interestAmount: interestAmount,
      insuranceFee: insuranceFee,
      compulsorySaving: compulsorySaving,
      totalAmount: totalAmount,
      dueDate: dueDate,
      status: status ?? this.status,
      debtGroup: debtGroup,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }

  @override
  List<Object?> get props => [
        scheduleId,
        contractCode,
        customerCode,
        customerName,
        groupCode,
        periodNumber,
        principalAmount,
        interestAmount,
        insuranceFee,
        compulsorySaving,
        totalAmount,
        dueDate,
        status,
        debtGroup,
        collectedAmount,
        collectedAt,
      ];
}
