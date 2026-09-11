import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class GenerateMmqrRequested extends PaymentEvent {
  final String contractCode;
  final double amountMmk;

  const GenerateMmqrRequested({
    required this.contractCode,
    required this.amountMmk,
  });

  @override
  List<Object?> get props => [contractCode, amountMmk];
}

class PollPaymentStatusRequested extends PaymentEvent {
  final String transactionReference;
  final String contractCode;
  final double amountMmk;

  const PollPaymentStatusRequested({
    required this.transactionReference,
    required this.contractCode,
    required this.amountMmk,
  });

  @override
  List<Object?> get props => [transactionReference, contractCode, amountMmk];
}

class LaunchWalletRequested extends PaymentEvent {
  final String walletScheme;
  final String mmqrPayload;

  const LaunchWalletRequested({
    required this.walletScheme,
    required this.mmqrPayload,
  });

  @override
  List<Object?> get props => [walletScheme, mmqrPayload];
}

class ResetPaymentRequested extends PaymentEvent {
  const ResetPaymentRequested();
}
