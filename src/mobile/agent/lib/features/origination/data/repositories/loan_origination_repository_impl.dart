import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/sync_operation.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/loan_application.dart';
import '../repositories/loan_origination_repository.dart';

/// Implementation of [LoanOriginationRepository] persisting applications offline with Outbox pattern.
class LoanOriginationRepositoryImpl implements LoanOriginationRepository {
  final ApiClient _apiClient;
  final AppDatabase _database;
  final Uuid _uuid;

  LoanOriginationRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase database,
    Uuid? uuid,
  })  : _apiClient = apiClient,
        _database = database,
        _uuid = uuid ?? const Uuid();

  @override
  Future<LoanApplication> submitLoanApplication(LoanApplication application) async {
    AppLogger.info('Submitting loan application: ${application.applicationId} for ${application.customerName}', tag: 'OriginationRepo');

    // 1. Enqueue into local_sync_queue with Idempotency UUIDv4
    final queueId = _uuid.v4();
    final payloadJson = jsonEncode(application.toJson());

    await _database.enqueueSyncOperation(
      LocalSyncQueueTableCompanion(
        queueId: Value(queueId),
        operationType: const Value('LOAN_APPLICATION'),
        entityId: Value(application.applicationId),
        payloadJson: Value(payloadJson),
        idempotencyKey: Value(application.idempotencyKey),
        status: const Value('PENDING'),
        createdAt: Value(DateTime.now()),
      ),
    );

    // 2. Attempt online submission if network is available
    try {
      final response = await _apiClient.post(
        '/api/v1/mobile/loans/apply',
        data: application.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _database.updateSyncQueueStatus(queueId, SyncStatus.completed);
        AppLogger.info('Loan application successfully synced to Gateway immediately.', tag: 'OriginationRepo');
        return application;
      }
    } catch (e) {
      AppLogger.warn('Immediate Gateway submission failed. Application safely queued offline: $e', tag: 'OriginationRepo');
    }

    return application;
  }

  @override
  Future<List<LoanApplication>> getPendingApplications() async {
    final queueItems = await (_database.select(_database.localSyncQueueTable)
          ..where((t) => t.operationType.equals(SyncOperation.loanApplication.code) 
              & t.status.equals(SyncStatus.pending.code)))
        .get();

    AppLogger.debug('Retrieved ${queueItems.length} pending loan applications from sync queue.', tag: 'OriginationRepo');
    return [];
  }
}
