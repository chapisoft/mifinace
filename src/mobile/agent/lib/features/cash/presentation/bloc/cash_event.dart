import 'package:equatable/equatable.dart';

abstract class CashEvent extends Equatable {
  const CashEvent();

  @override
  List<Object?> get props => [];
}

class LoadCashSummaryRequested extends CashEvent {
  final String officerId;

  const LoadCashSummaryRequested({required this.officerId});

  @override
  List<Object?> get props => [officerId];
}

class GenerateHandoverQrRequested extends CashEvent {
  final String officerId;

  const GenerateHandoverQrRequested({required this.officerId});

  @override
  List<Object?> get props => [officerId];
}

class ConfirmHandoverCompletedRequested extends CashEvent {
  final String officerId;
  final String referenceId;

  const ConfirmHandoverCompletedRequested({
    required this.officerId,
    required this.referenceId,
  });

  @override
  List<Object?> get props => [officerId, referenceId];
}
