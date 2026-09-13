import 'package:equatable/equatable.dart';

/// Entity đại diện cho bản ghi giao dịch thu nợ / thanh toán trong bảng CSDL `SYS_REPAYMENT_TRANSACTION`.
class CustomerTransaction extends Equatable {
  final String transactionId;
  final String contractCode;
  final String customerCode;
  final String customerName;
  final String groupCode;
  final int periodNumber;
  final double principalAmountMmk;
  final double interestAmountMmk;
  final double insuranceFeeMmk;
  final double compulsorySavingMmk;
  final double totalAmountMmk;
  final String paymentMethod; // 'CASH', 'MMQR', 'KBZ_PAY', 'WAVE_PAY', 'BANK_TRANSFER'
  final String status; // 'SETTLED', 'COLLECTED', 'FAILED'
  final DateTime transactionTime;
  final String collectedBy;
  final String? notes;

  const CustomerTransaction({
    required this.transactionId,
    required this.contractCode,
    required this.customerCode,
    required this.customerName,
    required this.groupCode,
    required this.periodNumber,
    required this.principalAmountMmk,
    required this.interestAmountMmk,
    required this.insuranceFeeMmk,
    required this.compulsorySavingMmk,
    required this.totalAmountMmk,
    required this.paymentMethod,
    required this.status,
    required this.transactionTime,
    required this.collectedBy,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'contractCode': contractCode,
      'customerCode': customerCode,
      'customerName': customerName,
      'groupCode': groupCode,
      'periodNumber': periodNumber,
      'principalAmountMmk': principalAmountMmk,
      'interestAmountMmk': interestAmountMmk,
      'insuranceFeeMmk': insuranceFeeMmk,
      'compulsorySavingMmk': compulsorySavingMmk,
      'totalAmountMmk': totalAmountMmk,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionTime': transactionTime.toIso8601String(),
      'collectedBy': collectedBy,
      'notes': notes,
    };
  }

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) {
    return CustomerTransaction(
      transactionId: json['transactionId']?.toString() ?? '',
      contractCode: json['contractCode']?.toString() ?? '',
      customerCode: json['customerCode']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      groupCode: json['groupCode']?.toString() ?? '',
      periodNumber: (json['periodNumber'] as num?)?.toInt() ?? 1,
      principalAmountMmk: (json['principalAmountMmk'] as num?)?.toDouble() ?? (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
      interestAmountMmk: (json['interestAmountMmk'] as num?)?.toDouble() ?? (json['interestAmount'] as num?)?.toDouble() ?? 0.0,
      insuranceFeeMmk: (json['insuranceFeeMmk'] as num?)?.toDouble() ?? (json['insuranceFee'] as num?)?.toDouble() ?? 0.0,
      compulsorySavingMmk: (json['compulsorySavingMmk'] as num?)?.toDouble() ?? (json['compulsorySaving'] as num?)?.toDouble() ?? 0.0,
      totalAmountMmk: (json['totalAmountMmk'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'CASH',
      status: json['status']?.toString() ?? 'SETTLED',
      transactionTime: json['transactionTime'] != null
          ? DateTime.tryParse(json['transactionTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      collectedBy: json['collectedBy']?.toString() ?? 'SYSTEM',
      notes: json['notes']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        contractCode,
        customerCode,
        customerName,
        groupCode,
        periodNumber,
        principalAmountMmk,
        interestAmountMmk,
        insuranceFeeMmk,
        compulsorySavingMmk,
        totalAmountMmk,
        paymentMethod,
        status,
        transactionTime,
        collectedBy,
        notes,
      ];
}
