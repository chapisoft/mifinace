/// Status of offline sync queue records.
enum SyncStatus {
  pending('PENDING'),
  syncing('SYNCING'),
  completed('COMPLETED'),
  failed('FAILED'),
  conflict('CONFLICT');

  final String code;
  const SyncStatus(this.code);

  static SyncStatus fromCode(String? code) {
    if (code == null) return SyncStatus.pending;
    final upper = code.toUpperCase();
    if (upper == 'SYNCED' || upper == 'SUCCESS' || upper == 'COMPLETED') {
      return SyncStatus.completed;
    }
    if (upper == 'FAILED' || upper == 'ERROR') {
      return SyncStatus.failed;
    }
    if (upper == 'SYNCING') {
      return SyncStatus.syncing;
    }
    if (upper == 'CONFLICT') {
      return SyncStatus.conflict;
    }
    for (final status in SyncStatus.values) {
      if (status.code == upper || status.name.toUpperCase() == upper) {
        return status;
      }
    }
    return SyncStatus.pending;
  }
}
