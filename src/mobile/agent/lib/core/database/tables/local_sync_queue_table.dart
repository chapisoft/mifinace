import 'package:drift/drift.dart';

/// Local table for the Offline Sync Queue (Hàng đợi đồng bộ ngoại tuyến).
@DataClassName('LocalSyncQueueItem')
class LocalSyncQueueTable extends Table {
  TextColumn get queueId => text().named('queue_id')();
  TextColumn get operationType => text().named('operation_type')(); // COLLECT_REPAYMENT, LOAN_APPLICATION, etc.
  TextColumn get aggregateId => text().named('aggregate_id')();
  TextColumn get payloadJson => text().named('payload_json')();
  TextColumn get status => text().named('status')(); // PENDING, SYNCING, COMPLETED, FAILED, CONFLICT
  IntColumn get retryCount => integer().named('retry_count').withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().named('max_retries').withDefault(const Constant(5))();
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get processedAt => dateTime().named('processed_at').nullable()();
  TextColumn get errorMessage => text().named('error_message').nullable()();

  @override
  Set<Column> get primaryKey => {queueId};
}
