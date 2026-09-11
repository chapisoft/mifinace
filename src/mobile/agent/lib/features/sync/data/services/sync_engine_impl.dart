import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/sync_summary.dart';
import '../../domain/services/pull_sync_service.dart';
import '../../domain/services/push_batch_sync_service.dart';
import '../../domain/services/sync_engine.dart';

/// Implementation of [SyncEngine] orchestrating background connectivity monitoring & two-way synchronization.
class SyncEngineImpl implements SyncEngine {
  final PullSyncService _pullSyncService;
  final PushBatchSyncService _pushBatchSyncService;
  final AppDatabase _database;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  SyncEngineImpl({
    required PullSyncService pullSyncService,
    required PushBatchSyncService pushBatchSyncService,
    required AppDatabase database,
    Connectivity? connectivity,
  })  : _pullSyncService = pullSyncService,
        _pushBatchSyncService = pushBatchSyncService,
        _database = database,
        _connectivity = connectivity ?? Connectivity();

  @override
  void start() {
    AppLogger.info('Starting Two-Way Offline SyncEngine & Network Listener...', tag: 'SyncEngine');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet);
      if (hasConnection && !_isSyncing) {
        AppLogger.info('Network connection restored. Auto-triggering background delta sync...', tag: 'SyncEngine');
        triggerManualSync();
      }
    });
  }

  @override
  void stop() {
    AppLogger.info('Stopping Offline SyncEngine...', tag: 'SyncEngine');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  @override
  Future<SyncSummary> triggerManualSync() async {
    if (_isSyncing) {
      AppLogger.warn('Sync is already in progress. Ignoring duplicate trigger.', tag: 'SyncEngine');
      return getSyncSummary();
    }

    _isSyncing = true;
    AppLogger.info('=== Starting Two-Way Offline Synchronization Sequence ===', tag: 'SyncEngine');

    try {
      // Step 1: Push offline transactions first (FIFO priority)
      final pushedCount = await _pushBatchSyncService.pushPendingRepayments();
      AppLogger.info('Step 1 complete: Pushed $pushedCount repayments to Gateway.', tag: 'SyncEngine');

      // Step 2: Pull catalog updates from Gateway
      final pulledCount = await _pullSyncService.pullCatalogDelta(since: _lastSyncTime);
      AppLogger.info('Step 2 complete: Pulled $pulledCount updated records from Gateway.', tag: 'SyncEngine');

      _lastSyncTime = DateTime.now();
    } catch (e, stack) {
      AppLogger.error('SyncEngine encountered an error during sync cycle: $e', tag: 'SyncEngine', stackTrace: stack);
    } finally {
      _isSyncing = false;
    }

    return getSyncSummary();
  }

  @override
  Future<SyncSummary> getSyncSummary() async {
    final allQueueItems = await _database.select(_database.localSyncQueueTable).get();

    int pending = 0;
    int synced = 0;
    int failed = 0;

    for (final item in allQueueItems) {
      if (item.status == 'PENDING') {
        pending++;
      } else if (item.status == 'SYNCED') {
        synced++;
      } else if (item.status == 'FAILED') {
        failed++;
      }
    }

    final connectivityResults = await _connectivity.checkConnectivity();
    final isOnline = connectivityResults.any((r) => r != ConnectivityResult.none);

    return SyncSummary(
      pendingCount: pending,
      syncedCount: synced,
      failedCount: failed,
      lastSyncTime: _lastSyncTime,
      isOnline: isOnline,
    );
  }
}
