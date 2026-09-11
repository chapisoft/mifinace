import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/database/app_database.dart';
import 'package:bmf_agent_app/core/security/secure_storage_service.dart';
import 'package:bmf_agent_app/core/security/sqlcipher_key_manager.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    final secureStorage = SecureStorageService();
    final keyManager = SqlCipherKeyManager(secureStorage);
    // Use in-memory SQLite for testing
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()), keyManager);
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Encrypted Local Database Tests (TASK-AGENT-02.1 & 02.2 & 02.3)', () {
    test('Insert and query Centers and Groups offline', () async {
      // 1. Insert Centers
      await db.insertOrUpdateCenters([
        LocalCentersTableCompanion(
          centerId: const Value('CTR-001'),
          centerCode: const Value('C-001'),
          centerName: const Value('Hlaing Tharyar Center 1'),
          meetingDay: const Value('MONDAY'),
          meetingTime: const Value('09:00 AM'),
          townshipCode: const Value('HTY'),
          officerId: const Value('OFFICER-01'),
          updatedAt: Value(DateTime.now()),
        ),
      ]);

      final centers = await db.getAllCenters();
      expect(centers.length, 1);
      expect(centers.first.centerCode, 'C-001');

      // 2. Insert Groups
      await db.insertOrUpdateGroups([
        LocalGroupsTableCompanion(
          groupId: const Value('GRP-001'),
          groupCode: const Value('G-001-A'),
          groupName: const Value('Mayangone Village Group 1'),
          centerCode: const Value('C-001'),
          leaderName: const Value('Daw Khin Win'),
          leaderPhone: const Value('0945001122'),
          memberCount: const Value(5),
          updatedAt: Value(DateTime.now()),
        ),
      ]);

      final groups = await db.getGroupsByCenter('C-001');
      expect(groups.length, 1);
      expect(groups.first.leaderName, 'Daw Khin Win');
    });

    test('Insert schedules and mark schedule paid locally', () async {
      await db.insertOrUpdateSchedules([
        LocalSchedulesTableCompanion(
          scheduleId: const Value('SCH-2026-001'),
          contractCode: const Value('LN-2026-001'),
          customerCode: const Value('CUST-1001'),
          customerName: const Value('U Aung San'),
          groupCode: const Value('G-001-A'),
          periodNumber: const Value(1),
          principalAmount: const Value(50000.0),
          interestAmount: const Value(4000.0),
          insuranceFee: const Value(1000.0),
          compulsorySaving: const Value(0.0),
          totalAmount: const Value(55000.0),
          dueDate: Value(DateTime.now()),
          status: const Value('PENDING'),
          debtGroup: const Value('STANDARD'),
          updatedAt: Value(DateTime.now()),
        ),
      ]);

      final schedules = await db.getSchedulesByGroup('G-001-A');
      expect(schedules.length, 1);
      expect(schedules.first.status, 'PENDING');

      // Mark paid locally
      await db.markSchedulePaidLocally('SCH-2026-001', 55000.0);
      final updatedSchedules = await db.getSchedulesByGroup('G-001-A');
      expect(updatedSchedules.first.status, 'PAID_LOCAL');
      expect(updatedSchedules.first.collectedAmount, 55000.0);
    });

    test('Enqueue offline sync operation and query pending items', () async {
      await db.enqueueSyncOperation(
        LocalSyncQueueTableCompanion(
          queueId: const Value('SYNC-001'),
          operationType: const Value('COLLECT_REPAYMENT'),
          aggregateId: const Value('LN-2026-001'),
          payloadJson: const Value('{"contractCode":"LN-2026-001","amount":55000}'),
          status: const Value('PENDING'),
          idempotencyKey: const Value('IDEMP-TEST-001'),
          createdAt: Value(DateTime.now()),
        ),
      );

      final pendingItems = await db.getPendingSyncQueueItems();
      expect(pendingItems.length, 1);
      expect(pendingItems.first.operationType, 'COLLECT_REPAYMENT');

      // Update status to COMPLETED
      await db.updateSyncQueueStatus('SYNC-001', 'COMPLETED');
      final remainingPending = await db.getPendingSyncQueueItems();
      expect(remainingPending.isEmpty, true);
    });
  });
}
