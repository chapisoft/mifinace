import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/services/sync_engine.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// Bloc managing Offline Synchronization lifecycle, background queues, and manual sync triggers.
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncEngine _syncEngine;

  SyncBloc({required SyncEngine syncEngine})
      : _syncEngine = syncEngine,
        super(const SyncInitial()) {
    on<LoadSyncSummaryRequested>(_onLoadSyncSummary);
    on<TriggerManualSyncRequested>(_onTriggerManualSync);
  }

  Future<void> _onLoadSyncSummary(LoadSyncSummaryRequested event, Emitter<SyncState> emit) async {
    emit(SyncLoading(summary: state.summary));
    try {
      final summary = await _syncEngine.getSyncSummary();
      AppLogger.info('Loaded sync summary: Pending=${summary.pendingCount}, Synced=${summary.syncedCount}', tag: 'SyncBloc');
      emit(SyncSuccessState(message: 'Sync status updated', summary: summary));
    } catch (e, stack) {
      AppLogger.error('Failed to get sync summary: $e', tag: 'SyncBloc', stackTrace: stack);
      emit(SyncFailureState(errorMessage: e.toString(), summary: state.summary));
    }
  }

  Future<void> _onTriggerManualSync(TriggerManualSyncRequested event, Emitter<SyncState> emit) async {
    emit(SyncInProgressState(statusMessage: 'Synchronizing with server...', summary: state.summary));
    try {
      final summary = await _syncEngine.triggerManualSync();
      AppLogger.info('Manual sync sequence completed successfully.', tag: 'SyncBloc');
      emit(SyncSuccessState(
        message: 'Two-way synchronization completed successfully.',
        summary: summary,
      ));
    } catch (e, stack) {
      AppLogger.error('Manual sync failed: $e', tag: 'SyncBloc', stackTrace: stack);
      emit(SyncFailureState(errorMessage: e.toString(), summary: state.summary));
    }
  }
}
