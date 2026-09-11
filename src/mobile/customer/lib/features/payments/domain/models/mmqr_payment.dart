import 'package:equatable/equatable.dart';

/// Entity representing dynamic MMQR (EMVCo) payment request for loan installment settlement.
class MmqrPayment extends Equatable {
  final String transactionReference;
  final String contractCode;
  final double amountMmk;
  final String mmqrPayload;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final String billerName;

  const MmqrPayment({
    required this.transactionReference,
    required this.contractCode,
    required this.amountMmk,
    required this.mmqrPayload,
    required this.generatedAt,
    required this.expiresAt,
    required this.billerName,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        transactionReference,
        contractCode,
        amountMmk,
        mmqrPayload,
        generatedAt,
        expiresAt,
        billerName,
      ];
}
