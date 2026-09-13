import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import '../enums/sync_status.dart';
import '../security/sqlcipher_key_manager.dart';
import '../utils/app_logger.dart';
import 'tables/local_centers_table.dart';
import 'tables/local_groups_table.dart';
import 'tables/local_schedules_table.dart';
import 'tables/local_repayments_table.dart';
import 'tables/local_sync_queue_table.dart';

part 'app_database.g.dart';

/// Central Drift Database for Offline-First Data Storage with SQLCipher AES-256 Encryption.
@DriftDatabase(tables: [
  LocalCentersTable,
  LocalGroupsTable,
  LocalSchedulesTable,
  LocalRepaymentsTable,
  LocalSyncQueueTable,
])
class AppDatabase extends _$AppDatabase {
  final SqlCipherKeyManager keyManager;

  AppDatabase(this.keyManager) : super(_openConnection(keyManager));

  AppDatabase.forTesting(super.connection, this.keyManager);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(SqlCipherKeyManager keyManager) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, AppConstants.databaseName));
      final password = await keyManager.getOrCreateMasterKey();

      AppLogger.info('Opening SQLCipher AES-256 encrypted database at: ${file.path}', tag: 'AppDatabase');

      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          // SQLCipher PRAGMA key configuration
          rawDb.execute("PRAGMA key = '$password';");
          rawDb.execute('PRAGMA cipher_page_size = 4096;');
          rawDb.execute('PRAGMA kdf_iter = 64000;');
          rawDb.execute('PRAGMA cipher_hmac_algorithm = HMAC_SHA256;');
          rawDb.execute('PRAGMA cipher_default_kdf_algorithm = PBKDF2_HMAC_SHA256;');
        },
      );
    });
  }

  // ---------------------------------------------------------------------------
  // DAO Helper Methods: Centers & Groups
  // ---------------------------------------------------------------------------

  Future<void> insertOrUpdateCenters(List<LocalCentersTableCompanion> centers) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(localCentersTable, centers);
    });
    AppLogger.debug('Synced ${centers.length} centers into local database', tag: 'AppDatabase');
  }

  Future<List<LocalCenter>> getAllCenters() => select(localCentersTable).get();

  Future<void> insertOrUpdateGroups(List<LocalGroupsTableCompanion> groups) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(localGroupsTable, groups);
    });
    AppLogger.debug('Synced ${groups.length} groups into local database', tag: 'AppDatabase');
  }

  Future<List<LocalGroup>> getGroupsByCenter(String centerCode) {
    return (select(localGroupsTable)..where((t) => t.centerCode.equals(centerCode))).get();
  }

  // ---------------------------------------------------------------------------
  // DAO Helper Methods: Schedules
  // ---------------------------------------------------------------------------

  Future<void> insertOrUpdateSchedules(List<LocalSchedulesTableCompanion> schedules) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(localSchedulesTable, schedules);
    });
    AppLogger.debug('Synced ${schedules.length} loan schedules into local database', tag: 'AppDatabase');
  }

  Future<List<LocalSchedule>> getSchedulesByGroup(String groupCode) {
    return (select(localSchedulesTable)..where((t) => t.groupCode.equals(groupCode))).get();
  }

  Future<void> markSchedulePaidLocally(String scheduleId, double collectedAmount) async {
    await (update(localSchedulesTable)..where((t) => t.scheduleId.equals(scheduleId))).write(
      LocalSchedulesTableCompanion(
        status: const Value('PAID_LOCAL'),
        collectedAmount: Value(collectedAmount),
        collectedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    AppLogger.info('Marked schedule $scheduleId as PAID_LOCAL ($collectedAmount MMK)', tag: 'AppDatabase');
  }

  // ---------------------------------------------------------------------------
  // DAO Helper Methods: Repayments & Sync Queue
  // ---------------------------------------------------------------------------

  Future<void> insertRepayment(LocalRepaymentsTableCompanion repayment) async {
    await into(localRepaymentsTable).insert(repayment);
    AppLogger.info('Recorded local repayment transaction: ${repayment.transactionId.value}', tag: 'AppDatabase');
  }

  Future<List<LocalRepayment>> getPendingRepayments() {
    return (select(localRepaymentsTable)..where((t) => t.syncStatus.equals(SyncStatus.pending.code))).get();
  }

  Future<void> enqueueSyncOperation(LocalSyncQueueTableCompanion syncItem) async {
    await into(localSyncQueueTable).insert(syncItem);
    AppLogger.info('Enqueued offline sync operation: ${syncItem.operationType.value} (ID: ${syncItem.queueId.value})',
        tag: 'AppDatabase');
  }

  Future<List<LocalSyncQueueItem>> getPendingSyncQueueItems({int limit = 50}) {
    return (select(localSyncQueueTable)
          ..where((t) => t.status.equals(SyncStatus.pending.code))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> updateSyncQueueStatus(String queueId, dynamic status, {String? errorMessage}) async {
    final statusStr = status is SyncStatus ? status.code : status.toString();
    await (update(localSyncQueueTable)..where((t) => t.queueId.equals(queueId))).write(
      LocalSyncQueueTableCompanion(
        status: Value(statusStr),
        processedAt: Value(DateTime.now()),
        errorMessage: Value(errorMessage),
      ),
    );
  }
}
