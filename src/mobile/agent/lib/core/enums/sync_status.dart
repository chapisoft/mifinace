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
    for (final status in SyncStatus.values) {
      if (status.code == code || status.name.toUpperCase() == code.toUpperCase()) {
        return status;
      }
    }
    return SyncStatus.pending;
  }
}
