import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/repayment_status.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_event.dart';
import 'collection_state.dart';

/// Bloc managing Collection Sheet schedules, field repayment execution, and offline transaction state.
class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CollectionRepository _collectionRepository;

  CollectionBloc({required CollectionRepository collectionRepository})
      : _collectionRepository = collectionRepository,
        super(const CollectionInitial()) {
    on<LoadSchedulesRequested>(_onLoadSchedules);
    on<SubmitRepaymentRequested>(_onSubmitRepayment);
  }

  Future<void> _onLoadSchedules(LoadSchedulesRequested event, Emitter<CollectionState> emit) async {
    emit(const CollectionLoading());
    try {
      final schedules = await _collectionRepository.getSchedulesByGroup(
        event.groupCode,
        forceRefresh: event.forceRefresh,
      );

      final totalDue = schedules.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
      final totalCollected = schedules
          .where((s) => s.status == RepaymentStatus.paidLocal || s.status == RepaymentStatus.settled)
          .fold<double>(0.0, (sum, s) => sum + (s.collectedAmount ?? s.totalAmount));

      AppLogger.info('Loaded ${schedules.length} schedules for group ${event.groupCode}', tag: 'CollectionBloc');
      emit(CollectionLoaded(
        schedules: schedules,
        totalDueAmount: totalDue,
        totalCollectedAmount: totalCollected,
      ));
    } catch (e, stack) {
      AppLogger.error('Failed to load collection sheet: $e', tag: 'CollectionBloc', stackTrace: stack);
      emit(CollectionError(e.toString()));
    }
  }

  Future<void> _onSubmitRepayment(SubmitRepaymentRequested event, Emitter<CollectionState> emit) async {
    try {
      final receipt = await _collectionRepository.collectRepayment(
        schedule: event.schedule,
        collectedAmount: event.amount,
        paymentMethod: event.method,
        collectorId: event.collectorId,
      );

      AppLogger.info('Repayment collected successfully: ${receipt.transactionId}', tag: 'CollectionBloc');
      emit(RepaymentSuccessState(receipt));

      // Reload schedules for the group
      add(LoadSchedulesRequested(event.schedule.groupCode));
    } catch (e, stack) {
      AppLogger.error('Failed to submit repayment: $e', tag: 'CollectionBloc', stackTrace: stack);
      emit(CollectionError(e.toString()));
    }
  }
}
