import 'package:equatable/equatable.dart';
import '../../domain/models/cash_summary.dart';

abstract class CashState extends Equatable {
  const CashState();

  @override
  List<Object?> get props => [];
}

class CashInitial extends CashState {
  const CashInitial();
}

class CashLoading extends CashState {
  const CashLoading();
}

class CashLoaded extends CashState {
  final CashSummary summary;

  const CashLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class CashHandoverQrGeneratedState extends CashState {
  final CashSummary summary;
  final String qrPayload;

  const CashHandoverQrGeneratedState({
    required this.summary,
    required this.qrPayload,
  });

  @override
  List<Object?> get props => [summary, qrPayload];
}

class CashHandoverSuccessState extends CashState {
  final String referenceId;

  const CashHandoverSuccessState(this.referenceId);

  @override
  List<Object?> get props => [referenceId];
}

class CashError extends CashState {
  final String errorMessage;

  const CashError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
