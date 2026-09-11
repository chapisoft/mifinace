import 'package:equatable/equatable.dart';
import '../../domain/models/mmqr_payment.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class MmqrGenerated extends PaymentState {
  final MmqrPayment payment;

  const MmqrGenerated(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentSuccess extends PaymentState {
  final String transactionReference;
  final String contractCode;
  final double amountMmk;
  final DateTime settledAt;

  const PaymentSuccess({
    required this.transactionReference,
    required this.contractCode,
    required this.amountMmk,
    required this.settledAt,
  });

  @override
  List<Object?> get props => [transactionReference, contractCode, amountMmk, settledAt];
}

class PaymentFailure extends PaymentState {
  final String errorMessage;

  const PaymentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
