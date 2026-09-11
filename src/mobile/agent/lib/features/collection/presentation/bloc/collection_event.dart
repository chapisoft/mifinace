import 'package:equatable/equatable.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../domain/entities/schedule_item.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedulesRequested extends CollectionEvent {
  final String groupCode;
  final bool forceRefresh;

  const LoadSchedulesRequested(this.groupCode, {this.forceRefresh = false});

  @override
  List<Object?> get props => [groupCode, forceRefresh];
}

class SubmitRepaymentRequested extends CollectionEvent {
  final ScheduleItem schedule;
  final double amount;
  final RepaymentMethod method;
  final String collectorId;

  const SubmitRepaymentRequested({
    required this.schedule,
    required this.amount,
    required this.method,
    required this.collectorId,
  });

  @override
  List<Object?> get props => [schedule, amount, method, collectorId];
}
