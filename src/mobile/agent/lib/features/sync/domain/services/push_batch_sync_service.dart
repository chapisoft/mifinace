/// Service interface for pushing pending field repayments in batches (max 50) with Idempotency UUIDv4.
abstract class PushBatchSyncService {
  /// Scans pending sync queue items and pushes them to the Backend BFF Gateway.
  /// Returns the number of successfully synchronized transactions.
  Future<int> pushPendingRepayments({int batchSize = 50});
}
