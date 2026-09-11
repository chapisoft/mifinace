import 'package:equatable/equatable.dart';
import '../../domain/models/customer_loan.dart';
import '../../domain/models/customer_schedule_item.dart';

abstract class CustomerLoanState extends Equatable {
  const CustomerLoanState();

  @override
  List<Object?> get props => [];
}

class LoanInitial extends CustomerLoanState {
  const LoanInitial();
}

class LoanLoading extends CustomerLoanState {
  const LoanLoading();
}

class LoanListLoaded extends CustomerLoanState {
  final List<CustomerLoan> loans;

  const LoanListLoaded(this.loans);

  @override
  List<Object?> get props => [loans];
}

class LoanScheduleLoaded extends CustomerLoanState {
  final String contractCode;
  final List<CustomerScheduleItem> schedules;

  const LoanScheduleLoaded({
    required this.contractCode,
    required this.schedules,
  });

  @override
  List<Object?> get props => [contractCode, schedules];
}

class LoanError extends CustomerLoanState {
  final String errorMessage;

  const LoanError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
