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
import '../entities/repayment_receipt.dart';
import '../entities/schedule_item.dart';
import '../domain/repositories/collection_repository.dart';

/// Implementation of CollectionRepository handling Offline-First local recording and Drift transactions.
class CollectionRepositoryImpl implements CollectionRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  CollectionRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase db,
  })  : _apiClient = apiClient,
        _db = db;

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
      AppLogger.warn('Network download failed for group $groupCode schedules: $e', tag: 'CollectionRepository');
    }

    return localSchedules.map(_mapLocalToEntity).toList();
  }

  @override
  Future<RepaymentReceipt> collectRepayment({
    required ScheduleItem schedule,
    required double collectedAmount,
    required RepaymentMethod paymentMethod,
    required String collectorId,
  }) async {
    final transactionId = 'TX-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final receiptNumber = 'REC-${DateTime.now().millisecondsSinceEpoch}';
    final idempotencyKey = _uuid.v4();
    final now = DateTime.now();

    AppLogger.info(
      'Executing field collection for contract=${schedule.contractCode}, period=${schedule.periodNumber}, amount=$collectedAmount MMK',
      tag: 'CollectionRepository',
    );

    // 1. Record transaction into local_repayments table
    await _db.insertRepayment(LocalRepaymentsTableCompanion(
      transactionId: Value(transactionId),
      contractCode: Value(schedule.contractCode),
      periodNumber: Value(schedule.periodNumber),
      customerCode: Value(schedule.customerCode),
      principalAmount: Value(schedule.principalAmount),
      interestAmount: Value(schedule.interestAmount),
      insuranceFee: Value(schedule.insuranceFee),
      compulsorySaving: Value(schedule.compulsorySaving),
      totalAmount: Value(collectedAmount),
      paymentMethod: Value(paymentMethod.code),
      receiptNumber: Value(receiptNumber),
      collectorId: Value(collectorId),
      collectedAt: Value(now),
      syncStatus: const Value('PENDING'),
      idempotencyKey: Value(idempotencyKey),
    ));

    // 2. Mark schedule as PAID_LOCAL in local_schedules
    await _db.markSchedulePaidLocally(schedule.scheduleId, collectedAmount);

    // 3. Enqueue into local_sync_queue
    final syncPayload = {
      'transactionId': transactionId,
      'contractCode': schedule.contractCode,
      'periodNumber': schedule.periodNumber,
      'customerCode': schedule.customerCode,
      'principalAmount': schedule.principalAmount,
      'interestAmount': schedule.interestAmount,
      'insuranceFee': schedule.insuranceFee,
      'compulsorySaving': schedule.compulsorySaving,
      'totalAmount': collectedAmount,
      'paymentMethod': paymentMethod.code,
      'receiptNumber': receiptNumber,
      'collectorUserId': collectorId,
      'collectedAt': DateFormatter.formatIsoDateTime(now),
    };

    await _db.enqueueSyncOperation(LocalSyncQueueTableCompanion(
      queueId: Value('SYNC-${_uuid.v4()}'),
      operationType: Value(SyncOperation.collectRepayment.code),
      aggregateId: Value(schedule.contractCode),
      payloadJson: Value(jsonEncode(syncPayload)),
      status: Value(SyncStatus.pending.code),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(now),
    ));

    return RepaymentReceipt(
      transactionId: transactionId,
      contractCode: schedule.contractCode,
      periodNumber: schedule.periodNumber,
      customerCode: schedule.customerCode,
      customerName: schedule.customerName,
      principalAmount: schedule.principalAmount,
      interestAmount: schedule.interestAmount,
      insuranceFee: schedule.insuranceFee,
      compulsorySaving: schedule.compulsorySaving,
      totalAmount: collectedAmount,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
      collectorId: collectorId,
      collectedAt: now,
      syncStatus: SyncStatus.pending,
      idempotencyKey: idempotencyKey,
    );
  }

  ScheduleItem _mapLocalToEntity(LocalSchedule s) {
    return ScheduleItem(
      scheduleId: s.scheduleId,
      contractCode: s.contractCode,
      customerCode: s.customerCode,
      customerName: s.customerName,
      groupCode: s.groupCode,
      periodNumber: s.periodNumber,
      principalAmount: s.principalAmount,
      interestAmount: s.interestAmount,
      insuranceFee: s.insuranceFee,
      compulsorySaving: s.compulsorySaving,
      totalAmount: s.totalAmount,
      dueDate: s.dueDate,
      status: RepaymentStatus.fromCode(s.status),
      debtGroup: DebtGroup.fromDays(0),
      collectedAmount: s.collectedAmount,
      collectedAt: s.collectedAt,
    );
  }
}
