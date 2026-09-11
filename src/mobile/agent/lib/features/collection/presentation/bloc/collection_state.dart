import 'package:equatable/equatable.dart';
import '../../domain/entities/repayment_receipt.dart';
import '../../domain/entities/schedule_item.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial();
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionLoaded extends CollectionState {
  final List<ScheduleItem> schedules;
  final double totalDueAmount;
  final double totalCollectedAmount;

  const CollectionLoaded({
    required this.schedules,
    required this.totalDueAmount,
    required this.totalCollectedAmount,
  });

  @override
  List<Object?> get props => [schedules, totalDueAmount, totalCollectedAmount];
}

class RepaymentSuccessState extends CollectionState {
  final RepaymentReceipt receipt;

  const RepaymentSuccessState(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object?> get props => [message];
}
