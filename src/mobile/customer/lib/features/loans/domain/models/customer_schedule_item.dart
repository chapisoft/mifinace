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
  final String? transactionId;
  final String? paymentMethod;

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
    this.transactionId,
    this.paymentMethod,
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
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    };
  }

  factory CustomerScheduleItem.fromJson(Map<String, dynamic> json) {
    final schedId = json['scheduleId']?.toString() ??
        '${json['contractCode'] ?? 'HD'}_${json['periodNumber'] ?? json['kyThu'] ?? 1}';
    final pNum = (json['periodNumber'] ?? json['kyThu'] as num?)?.toInt() ?? 1;

    DateTime dDate = DateTime.now();
    final rawDue = json['dueDate'] ?? json['ngayDenHan'];
    if (rawDue != null) {
      dDate = DateTime.tryParse(rawDue.toString()) ?? DateTime.now();
    }

    final pDue = (json['principalDueMmk'] ?? json['principalAmount'] ?? json['tienGoc'] as num?)?.toDouble() ?? 0.0;
    final iDue = (json['interestDueMmk'] ?? json['interestAmount'] ?? json['tienLai'] as num?)?.toDouble() ?? 0.0;
    final insDue = (json['insuranceFeeMmk'] ?? json['insuranceFee'] ?? json['phiBaoHiem'] as num?)?.toDouble() ?? 0.0;
    final sDue = (json['savingFeeMmk'] ?? json['compulsorySaving'] ?? json['tietKiemBatBuoc'] as num?)?.toDouble() ?? 0.0;
    final totDue = (json['totalDueMmk'] ?? json['totalAmount'] ?? json['tongTien'] as num?)?.toDouble() ?? (pDue + iDue + insDue + sDue);

    final rawStatus = (json['status'] ?? json['trangThai'])?.toString();
    final st = RepaymentStatus.fromCode(rawStatus);

    DateTime? pDate;
    final rawPaid = json['paidDate'] ?? json['collectedTime'];
    if (rawPaid != null) {
      pDate = DateTime.tryParse(rawPaid.toString());
    }

    final odDays = (json['overdueDays'] as num?)?.toInt() ?? 0;
    final dg = DebtGroup.fromCode(json['debtGroup']?.toString());

    return CustomerScheduleItem(
      scheduleId: schedId,
      periodNumber: pNum,
      dueDate: dDate,
      principalDueMmk: pDue,
      interestDueMmk: iDue,
      insuranceFeeMmk: insDue,
      savingFeeMmk: sDue,
      totalDueMmk: totDue,
      status: st,
      paidDate: pDate,
      overdueDays: odDays,
      debtGroup: dg,
      transactionId: json['transactionId']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
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
        transactionId,
        paymentMethod,
      ];
}
