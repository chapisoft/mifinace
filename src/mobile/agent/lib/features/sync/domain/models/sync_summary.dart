import 'package:equatable/equatable.dart';

/// Summary statistics of the offline synchronization engine.
class SyncSummary extends Equatable {
  final int pendingCount;
  final int syncedCount;
  final int failedCount;
  final DateTime? lastSyncTime;
  final bool isOnline;

  const SyncSummary({
    required this.pendingCount,
    required this.syncedCount,
    required this.failedCount,
    this.lastSyncTime,
    this.isOnline = true,
  });

  @override
  List<Object?> get props => [pendingCount, syncedCount, failedCount, lastSyncTime, isOnline];
}
