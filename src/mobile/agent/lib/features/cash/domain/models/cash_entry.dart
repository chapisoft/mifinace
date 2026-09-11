import 'package:equatable/equatable.dart';
import '../../../../core/enums/cash_transaction_type.dart';

/// Single cash movement entry recorded on the officer device.
class CashEntry extends Equatable {
  final String entryId;
  final CashTransactionType transactionType;
  final String referenceId;
  final String customerName;
  final double amountMmk;
  final DateTime timestamp;

  const CashEntry({
    required this.entryId,
    required this.transactionType,
    required this.referenceId,
    required this.customerName,
    required this.amountMmk,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'entryId': entryId,
      'transactionType': transactionType.code,
      'referenceId': referenceId,
      'customerName': customerName,
      'amountMmk': amountMmk,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CashEntry.fromJson(Map<String, dynamic> json) {
    return CashEntry(
      entryId: json['entryId'] as String,
      transactionType: CashTransactionType.fromCode(json['transactionType'] as String?),
      referenceId: json['referenceId'] as String,
      customerName: json['customerName'] as String,
      amountMmk: (json['amountMmk'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [entryId, transactionType, referenceId, customerName, amountMmk, timestamp];
}
