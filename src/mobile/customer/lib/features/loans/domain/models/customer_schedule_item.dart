import 'package:equatable/equatable.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/repayment_status.dart';

/// Entity representing an installment period in a borrower's repayment schedule.
class CustomerScheduleItem extends Equatable {
  final String scheduleId;
  final int periodNumber;
  final DateTime dueDate;
  final double principalDueMmk;
  final double interestDueMmk;
  final double insuranceFeeMmk;
  final double savingFeeMmk;
  final double totalDueMmk;
  final RepaymentStatus status;
  final DateTime? paidDate;
  final int overdueDays;
  final DebtGroup debtGroup;

  const CustomerScheduleItem({
    required this.scheduleId,
    required this.periodNumber,
    required this.dueDate,
    required this.principalDueMmk,
    required this.interestDueMmk,
    required this.insuranceFeeMmk,
    required this.savingFeeMmk,
    required this.totalDueMmk,
    required this.status,
    this.paidDate,
    required this.overdueDays,
    required this.debtGroup,
  });

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'periodNumber': periodNumber,
      'dueDate': dueDate.toIso8601String(),
      'principalDueMmk': principalDueMmk,
      'interestDueMmk': interestDueMmk,
      'insuranceFeeMmk': insuranceFeeMmk,
      'savingFeeMmk': savingFeeMmk,
      'totalDueMmk': totalDueMmk,
      'status': status.code,
      'paidDate': paidDate?.toIso8601String(),
      'overdueDays': overdueDays,
      'debtGroup': debtGroup.code,
    };
  }

  factory CustomerScheduleItem.fromJson(Map<String, dynamic> json) {
    return CustomerScheduleItem(
      scheduleId: json['scheduleId'] as String,
      periodNumber: json['periodNumber'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      principalDueMmk: (json['principalDueMmk'] as num).toDouble(),
      interestDueMmk: (json['interestDueMmk'] as num).toDouble(),
      insuranceFeeMmk: (json['insuranceFeeMmk'] as num).toDouble(),
      savingFeeMmk: (json['savingFeeMmk'] as num).toDouble(),
      totalDueMmk: (json['totalDueMmk'] as num).toDouble(),
      status: RepaymentStatus.fromCode(json['status'] as String?),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      overdueDays: json['overdueDays'] as int? ?? 0,
      debtGroup: DebtGroup.fromCode(json['debtGroup'] as String?),
    );
  }

  @override
  List<Object?> get props => [
        scheduleId,
        periodNumber,
        dueDate,
        principalDueMmk,
        interestDueMmk,
        insuranceFeeMmk,
        savingFeeMmk,
        totalDueMmk,
        status,
        paidDate,
        overdueDays,
        debtGroup,
      ];
}
