import '../models/sync_summary.dart';

/// Central Orchestrator managing two-way offline data synchronization.
abstract class SyncEngine {
  /// Starts automatic background connectivity listening and delta synchronization.
  void start();

  /// Stops background synchronization engine.
  void stop();

  /// Triggers an immediate manual two-way synchronization (Push pending first -> Pull updates).
  Future<SyncSummary> triggerManualSync();

  /// Gets the current synchronization summary.
  Future<SyncSummary> getSyncSummary();
}
