import 'package:equatable/equatable.dart';

abstract class CustomerLoanEvent extends Equatable {
  const CustomerLoanEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveLoansRequested extends CustomerLoanEvent {
  final String memberNrc;

  const LoadActiveLoansRequested(this.memberNrc);

  @override
  List<Object?> get props => [memberNrc];
}

class LoadLoanScheduleRequested extends CustomerLoanEvent {
  final String contractCode;

  const LoadLoanScheduleRequested(this.contractCode);

  @override
  List<Object?> get props => [contractCode];
}
