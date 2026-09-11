import 'package:equatable/equatable.dart';
import '../../domain/models/customer_saving_account.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {
  const SavingsInitial();
}

class SavingsLoading extends SavingsState {
  const SavingsLoading();
}

class SavingsLoaded extends SavingsState {
  final List<CustomerSavingAccount> accounts;

  const SavingsLoaded(this.accounts);

  double get totalSavingsBalanceMmk =>
      accounts.fold(0.0, (sum, acc) => sum + acc.balanceMmk);

  double get totalAccruedInterestMmk =>
      accounts.fold(0.0, (sum, acc) => sum + acc.accruedInterestMmk);

  @override
  List<Object?> get props => [accounts];
}

class SavingAccountOpenedSuccess extends SavingsState {
  final CustomerSavingAccount newAccount;

  const SavingAccountOpenedSuccess(this.newAccount);

  @override
  List<Object?> get props => [newAccount];
}

class SavingsFailure extends SavingsState {
  final String errorMessage;

  const SavingsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
