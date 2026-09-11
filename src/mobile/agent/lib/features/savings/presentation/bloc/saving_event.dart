import 'package:equatable/equatable.dart';
import '../../domain/models/saving_account.dart';

abstract class SavingEvent extends Equatable {
  const SavingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavingAccountsRequested extends SavingEvent {
  final String? centerCode;
  final String? query;

  const LoadSavingAccountsRequested({this.centerCode, this.query});

  @override
  List<Object?> get props => [centerCode, query];
}

class DepositSavingRequested extends SavingEvent {
  final String accountNumber;
  final String customerName;
  final double amountMmk;
  final String officerId;

  const DepositSavingRequested({
    required this.accountNumber,
    required this.customerName,
    required this.amountMmk,
    required this.officerId,
  });

  @override
  List<Object?> get props => [accountNumber, customerName, amountMmk, officerId];
}

class OpenSavingAccountRequested extends SavingEvent {
  final SavingAccount account;
  final double initialDepositMmk;

  const OpenSavingAccountRequested({
    required this.account,
    required this.initialDepositMmk,
  });

  @override
  List<Object?> get props => [account, initialDepositMmk];
}
