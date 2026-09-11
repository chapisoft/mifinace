import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/features/sync/domain/models/sync_summary.dart';
import 'package:bmf_agent_app/features/sync/domain/services/sync_engine.dart';
import 'package:bmf_agent_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:bmf_agent_app/features/sync/presentation/bloc/sync_event.dart';
import 'package:bmf_agent_app/features/sync/presentation/bloc/sync_state.dart';

class MockSyncEngine implements SyncEngine {
  bool shouldThrowError = false;

  SyncSummary currentSummary = const SyncSummary(
    pendingCount: 5,
    syncedCount: 20,
    failedCount: 0,
    isOnline: true,
  );

  @override
  void start() {}

  @override
  void stop() {}

  @override
  Future<SyncSummary> getSyncSummary() async {
    if (shouldThrowError) throw Exception('Database read error');
    return currentSummary;
  }

  @override
  Future<SyncSummary> triggerManualSync() async {
    if (shouldThrowError) throw Exception('Network timeout during sync');
    currentSummary = SyncSummary(
      pendingCount: 0,
      syncedCount: currentSummary.syncedCount + currentSummary.pendingCount,
      failedCount: 0,
      lastSyncTime: DateTime.now(),
      isOnline: true,
    );
    return currentSummary;
  }
}

void main() {
  group('SyncBloc Tests (TASK-AGENT-06)', () {
    late MockSyncEngine mockSyncEngine;
    late SyncBloc syncBloc;

    setUp(() {
      mockSyncEngine = MockSyncEngine();
      syncBloc = SyncBloc(syncEngine: mockSyncEngine);
    });

    tearDown(() {
      syncBloc.close();
    });

    test('Initial state is SyncInitial', () {
      expect(syncBloc.state, equals(const SyncInitial()));
    });

    test('LoadSyncSummaryRequested emits [SyncLoading, SyncSuccessState] with current summary', () async {
      final expectedStates = [
        isA<SyncLoading>(),
        isA<SyncSuccessState>().having((s) => s.summary?.pendingCount, 'pendingCount', 5),
      ];

      expectLater(syncBloc.stream, emitsInOrder(expectedStates));

      syncBloc.add(const LoadSyncSummaryRequested());
    });

    test('TriggerManualSyncRequested runs two-way sync and clears pending records', () async {
      final expectedStates = [
        isA<SyncInProgressState>(),
        isA<SyncSuccessState>().having((s) => s.summary?.pendingCount, 'pendingCount', 0),
      ];

      expectLater(syncBloc.stream, emitsInOrder(expectedStates));

      syncBloc.add(const TriggerManualSyncRequested());
    });

    test('TriggerManualSyncRequested emits SyncFailureState on error', () async {
      mockSyncEngine.shouldThrowError = true;

      final expectedStates = [
        isA<SyncInProgressState>(),
        isA<SyncFailureState>().having((s) => s.errorMessage, 'errorMessage', contains('Network timeout')),
      ];

      expectLater(syncBloc.stream, emitsInOrder(expectedStates));

      syncBloc.add(const TriggerManualSyncRequested());
    });
  });
}
