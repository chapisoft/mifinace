import 'package:equatable/equatable.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../../../core/enums/sync_status.dart';

/// Entity representing an executed field repayment transaction and printed receipt.
class RepaymentReceipt extends Equatable {
  final String transactionId;
  final String contractCode;
  final int periodNumber;
  final String customerCode;
  final String customerName;
  final double principalAmount;
  final double interestAmount;
  final double insuranceFee;
  final double compulsorySaving;
  final double totalAmount;
  final RepaymentMethod paymentMethod;
  final String receiptNumber;
  final String collectorId;
  final DateTime collectedAt;
  final SyncStatus syncStatus;
  final String idempotencyKey;

  const RepaymentReceipt({
    required this.transactionId,
    required this.contractCode,
    required this.periodNumber,
    required this.customerCode,
    required this.customerName,
    required this.principalAmount,
    required this.interestAmount,
    required this.insuranceFee,
    required this.compulsorySaving,
    required this.totalAmount,
    required this.paymentMethod,
    required this.receiptNumber,
    required this.collectorId,
    required this.collectedAt,
    required this.syncStatus,
    required this.idempotencyKey,
  });

  @override
  List<Object?> get props => [
        transactionId,
        contractCode,
        periodNumber,
        customerCode,
        customerName,
        principalAmount,
        interestAmount,
        insuranceFee,
        compulsorySaving,
        totalAmount,
        paymentMethod,
        receiptNumber,
        collectorId,
        collectedAt,
        syncStatus,
        idempotencyKey,
      ];
}
