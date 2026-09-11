import 'package:equatable/equatable.dart';
import '../../domain/models/saving_account.dart';
import '../../domain/models/saving_deposit.dart';

abstract class SavingState extends Equatable {
  const SavingState();

  @override
  List<Object?> get props => [];
}

class SavingInitial extends SavingState {
  const SavingInitial();
}

class SavingLoading extends SavingState {
  const SavingLoading();
}

class SavingLoaded extends SavingState {
  final List<SavingAccount> accounts;
  final String? activeCenterCode;
  final String? query;

  const SavingLoaded({
    required this.accounts,
    this.activeCenterCode,
    this.query,
  });

  @override
  List<Object?> get props => [accounts, activeCenterCode, query];
}

class SavingDepositSuccessState extends SavingState {
  final SavingDeposit deposit;

  const SavingDepositSuccessState(this.deposit);

  @override
  List<Object?> get props => [deposit];
}

class SavingOpenSuccessState extends SavingState {
  final SavingAccount account;

  const SavingOpenSuccessState(this.account);

  @override
  List<Object?> get props => [account];
}

class SavingError extends SavingState {
  final String errorMessage;

  const SavingError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
