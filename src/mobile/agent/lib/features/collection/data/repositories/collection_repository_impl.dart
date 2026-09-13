import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../../../core/enums/repayment_status.dart';
import '../../../../core/enums/sync_operation.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/repayment_receipt.dart';
import '../../domain/entities/schedule_item.dart';
import '../../domain/repositories/collection_repository.dart';

/// Implementation of CollectionRepository handling Offline-First local recording, Drift transactions and auto-seeding.
class CollectionRepositoryImpl implements CollectionRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  CollectionRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase db,
  })  : _apiClient = apiClient,
        _db = db;

  List<LocalSchedulesTableCompanion> _getDefaultSchedules(String groupCode) {
    final now = DateTime.now();
    return [
      LocalSchedulesTableCompanion(
        scheduleId: const Value('HD-2026-001_8'),
        contractCode: const Value('HD-2026-001'),
        customerCode: const Value('CUST-001'),
        customerName: const Value('Daw Khin Myint'),
        groupCode: Value(groupCode),
        periodNumber: const Value(8),
        principalAmount: const Value(100000.0),
        interestAmount: const Value(15000.0),
        insuranceFee: const Value(5000.0),
        compulsorySaving: const Value(5000.0),
        totalAmount: const Value(125000.0),
        dueDate: Value(now),
        status: const Value('PENDING'),
        debtGroup: Value(DebtGroup.fromDays(0).code),
        updatedAt: Value(now),
      ),
      LocalSchedulesTableCompanion(
        scheduleId: const Value('HD-2026-002_6'),
        contractCode: const Value('HD-2026-002'),
        customerCode: const Value('CUST-002'),
        customerName: const Value('Daw Nilar Myint'),
        groupCode: Value(groupCode),
        periodNumber: const Value(6),
        principalAmount: const Value(120000.0),
        interestAmount: const Value(20000.0),
        insuranceFee: const Value(5000.0),
        compulsorySaving: const Value(5000.0),
        totalAmount: const Value(150000.0),
        dueDate: Value(now),
        status: const Value('PENDING'),
        debtGroup: Value(DebtGroup.fromDays(0).code),
        updatedAt: Value(now),
      ),
      LocalSchedulesTableCompanion(
        scheduleId: const Value('HD-2026-003_4'),
        contractCode: const Value('HD-2026-003'),
        customerCode: const Value('CUST-003'),
        customerName: const Value('Daw Hla Hla Than'),
        groupCode: Value(groupCode),
        periodNumber: const Value(4),
        principalAmount: const Value(90000.0),
        interestAmount: const Value(12000.0),
        insuranceFee: const Value(4000.0),
        compulsorySaving: const Value(4000.0),
        totalAmount: const Value(110000.0),
        dueDate: Value(now),
        status: const Value('PENDING'),
        debtGroup: Value(DebtGroup.fromDays(0).code),
        updatedAt: Value(now),
      ),
      LocalSchedulesTableCompanion(
        scheduleId: const Value('HD-2026-004_3'),
        contractCode: const Value('HD-2026-004'),
        customerCode: const Value('CUST-004'),
        customerName: const Value('Daw San San Maw'),
        groupCode: Value(groupCode),
        periodNumber: const Value(3),
        principalAmount: const Value(80000.0),
        interestAmount: const Value(9000.0),
        insuranceFee: const Value(3000.0),
        compulsorySaving: const Value(3000.0),
        totalAmount: const Value(95000.0),
        dueDate: Value(now),
        status: const Value('PENDING'),
        debtGroup: Value(DebtGroup.fromDays(0).code),
        updatedAt: Value(now),
      ),
      LocalSchedulesTableCompanion(
        scheduleId: const Value('HD-2026-005_5'),
        contractCode: const Value('HD-2026-005'),
        customerCode: const Value('CUST-005'),
        customerName: const Value('Daw Aye Aye Mar'),
        groupCode: Value(groupCode),
        periodNumber: const Value(5),
        principalAmount: const Value(110000.0),
        interestAmount: const Value(16000.0),
        insuranceFee: const Value(5000.0),
        compulsorySaving: const Value(4000.0),
        totalAmount: const Value(135000.0),
        dueDate: Value(now),
        status: const Value('PENDING'),
        debtGroup: Value(DebtGroup.fromDays(0).code),
        updatedAt: Value(now),
      ),
    ];
  }

  @override
  Future<List<ScheduleItem>> getSchedulesByGroup(String groupCode, {bool forceRefresh = false}) async {
    // 1. Check local encrypted Drift database first
    final localSchedules = await _db.getSchedulesByGroup(groupCode);
    if (localSchedules.isNotEmpty && !forceRefresh) {
      AppLogger.debug('Returning ${localSchedules.length} schedules from local SQLite for group $groupCode',
          tag: 'CollectionRepository');
      return localSchedules.map(_mapLocalToEntity).toList();
    }

    // 2. Fetch from BFF Gateway if empty or forced refresh
    try {
      AppLogger.info('Downloading loan schedules from BFF Gateway for group $groupCode', tag: 'CollectionRepository');
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getDueSchedules,
        queryParameters: {
          'groupCode': groupCode,
          'dueDate': DateFormatter.formatIsoDate(DateTime.now()),
        },
      );

      if (response.data != null && response.data!['data'] is List) {
        final list = response.data!['data'] as List<dynamic>;
        final companions = <LocalSchedulesTableCompanion>[];

        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final total = (map['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final principal = (map['principalAmount'] as num?)?.toDouble() ?? 0.0;
          final interest = (map['interestAmount'] as num?)?.toDouble() ?? 0.0;
          final insurance = (map['insuranceFee'] as num?)?.toDouble() ?? 0.0;
          final saving = (map['compulsorySaving'] as num?)?.toDouble() ?? 0.0;
          final dueDate = DateFormatter.parseIsoDate(map['dueDate']?.toString()) ?? DateTime.now();
          final statusStr = map['status']?.toString() ?? 'PENDING';

          companions.add(LocalSchedulesTableCompanion(
            scheduleId: Value('${map['contractCode']}_${map['periodNumber']}'),
            contractCode: Value(map['contractCode']?.toString() ?? ''),
            customerCode: Value(map['customerCode']?.toString() ?? ''),
            customerName: Value(map['customerName']?.toString() ?? ''),
            groupCode: Value(groupCode),
            periodNumber: Value((map['periodNumber'] as num?)?.toInt() ?? 1),
            principalAmount: Value(principal),
            interestAmount: Value(interest),
            insuranceFee: Value(insurance),
            compulsorySaving: Value(saving),
            totalAmount: Value(total),
            dueDate: Value(dueDate),
            status: Value(statusStr),
            debtGroup: Value(DebtGroup.fromDays(0).code),
            updatedAt: Value(DateTime.now()),
          ));
        }

        await _db.insertOrUpdateSchedules(companions);
        final refreshed = await _db.getSchedulesByGroup(groupCode);
        return refreshed.map(_mapLocalToEntity).toList();
      }
    } catch (e) {
      AppLogger.warn('Network download failed for group $groupCode schedules, falling back to local/seed: $e',
          tag: 'CollectionRepository');
    }

    if (localSchedules.isNotEmpty) {
      return localSchedules.map(_mapLocalToEntity).toList();
    }

    // Auto-seed demo schedules for group
    final defaultCompanions = _getDefaultSchedules(groupCode);
    await _db.insertOrUpdateSchedules(defaultCompanions);
    final seeded = await _db.getSchedulesByGroup(groupCode);
    return seeded.map(_mapLocalToEntity).toList();
  }

  @override
  Future<RepaymentReceipt> collectRepayment({
    required ScheduleItem schedule,
    required double collectedAmount,
    required RepaymentMethod paymentMethod,
    required String collectorId,
    String? referenceCode,
  }) async {
    final txId = 'TX-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final receiptNo = 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final now = DateTime.now();

    AppLogger.info('Recording repayment $txId for contract ${schedule.contractCode} (Amount: $collectedAmount MMK)',
        tag: 'CollectionRepository');

    // 1. Write repayment entry to local SQLite
    await _db.insertRepayment(LocalRepaymentsTableCompanion(
      transactionId: Value(txId),
      receiptNumber: Value(receiptNo),
      contractCode: Value(schedule.contractCode),
      customerCode: Value(schedule.customerCode),
      periodNumber: Value(schedule.periodNumber),
      principalAmount: Value(schedule.principalAmount),
      interestAmount: Value(schedule.interestAmount),
      insuranceFee: Value(schedule.insuranceFee),
      compulsorySaving: Value(schedule.compulsorySaving),
      totalAmount: Value(collectedAmount),
      paymentMethod: Value(paymentMethod.code),
      collectorId: Value(collectorId),
      collectedAt: Value(now),
      syncStatus: Value(SyncStatus.pending.code),
      idempotencyKey: Value('IDEMP-$txId'),
    ));

    // 2. Mark schedule as paid locally in Drift
    await _db.markSchedulePaidLocally(schedule.scheduleId, collectedAmount);

    // 3. Enqueue to Offline Sync Engine Outbox Queue
    final payloadJson = jsonEncode({
      'transactionId': txId,
      'receiptNumber': receiptNo,
      'contractCode': schedule.contractCode,
      'customerCode': schedule.customerCode,
      'periodNumber': schedule.periodNumber,
      'collectedAmount': collectedAmount,
      'paymentMethod': paymentMethod.code,
      'collectorId': collectorId,
      'collectionTime': now.toIso8601String(),
      'referenceCode': referenceCode,
    });

    await _db.enqueueSyncOperation(LocalSyncQueueTableCompanion(
      queueId: Value('Q-${_uuid.v4()}'),
      operationType: Value(SyncOperation.collectRepayment.code),
      aggregateId: Value(txId),
      payloadJson: Value(payloadJson),
      status: Value(SyncStatus.pending.code),
      idempotencyKey: Value('IDEMP-$txId'),
      createdAt: Value(now),
    ));

    return RepaymentReceipt(
      receiptNumber: receiptNo,
      transactionId: txId,
      contractCode: schedule.contractCode,
      customerName: schedule.customerName,
      customerCode: schedule.customerCode,
      periodNumber: schedule.periodNumber,
      principalAmount: schedule.principalAmount,
      interestAmount: schedule.interestAmount,
      insuranceFee: schedule.insuranceFee,
      compulsorySaving: schedule.compulsorySaving,
      totalAmount: collectedAmount,
      paymentMethod: paymentMethod,
      collectorId: collectorId,
      collectedAt: now,
      syncStatus: SyncStatus.pending,
      idempotencyKey: 'IDEMP-$txId',
    );
  }

  ScheduleItem _mapLocalToEntity(LocalSchedule local) {
    return ScheduleItem(
      scheduleId: local.scheduleId,
      contractCode: local.contractCode,
      customerCode: local.customerCode,
      customerName: local.customerName,
      groupCode: local.groupCode,
      periodNumber: local.periodNumber,
      principalAmount: local.principalAmount,
      interestAmount: local.interestAmount,
      insuranceFee: local.insuranceFee,
      compulsorySaving: local.compulsorySaving,
      totalAmount: local.totalAmount,
      dueDate: local.dueDate,
      status: RepaymentStatus.fromCode(local.status),
      debtGroup: DebtGroup.fromCode(local.debtGroup),
      collectedAmount: local.collectedAmount,
      collectedAt: local.collectedAt,
    );
  }
}
