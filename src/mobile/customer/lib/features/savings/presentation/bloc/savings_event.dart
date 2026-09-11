import 'package:equatable/equatable.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavingsAccountsRequested extends SavingsEvent {
  final String memberNrc;

  const LoadSavingsAccountsRequested(this.memberNrc);

  @override
  List<Object?> get props => [memberNrc];
}

class OpenSavingAccountRequested extends SavingsEvent {
  final String memberNrc;
  final double initialDepositMmk;
  final int tenureMonths;
  final String beneficiaryName;

  const OpenSavingAccountRequested({
    required this.memberNrc,
    required this.initialDepositMmk,
    required this.tenureMonths,
    required this.beneficiaryName,
  });

  @override
  List<Object?> get props => [memberNrc, initialDepositMmk, tenureMonths, beneficiaryName];
}
