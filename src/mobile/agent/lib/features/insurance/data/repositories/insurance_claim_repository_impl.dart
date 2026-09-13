import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/insurance_claim.dart';
import '../../domain/repositories/insurance_claim_repository.dart';

/// Implementation of [InsuranceClaimRepository] with offline-first SQLite synchronization.
class InsuranceClaimRepositoryImpl implements InsuranceClaimRepository {
  final ApiClient _apiClient;
  final AppDatabase _database;
  final Uuid _uuid;

  final List<InsuranceClaim> _cachedClaims = [];

  InsuranceClaimRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase database,
    Uuid? uuid,
  })  : _apiClient = apiClient,
        _database = database,
        _uuid = uuid ?? const Uuid();

  @override
  Future<InsuranceClaim> submitClaim(InsuranceClaim claim) async {
    AppLogger.info('Submitting field insurance claim: ${claim.claimId} for member ${claim.memberName}', tag: 'ClaimRepo');

    _cachedClaims.add(claim);

    // 1. Enqueue into SQLite local_sync_queue
    final queueId = _uuid.v4();
    final payloadJson = jsonEncode(claim.toJson());

    await _database.enqueueSyncOperation(
      LocalSyncQueueTableCompanion(
        queueId: Value(queueId),
        operationType: const Value('INSURANCE_CLAIM'),
        aggregateId: Value(claim.claimId),
        payloadJson: Value(payloadJson),
        idempotencyKey: Value(claim.idempotencyKey),
        status: const Value('PENDING'),
        createdAt: Value(DateTime.now()),
      ),
    );

    // 2. Attempt online submission if network is available
    try {
      final response = await _apiClient.post(
        '/api/v1/mobile/insurance/claims',
        data: claim.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _database.updateSyncQueueStatus(queueId, SyncStatus.completed);
        AppLogger.info('Insurance claim synced to Township core immediately: ${claim.claimId}', tag: 'ClaimRepo');
      }
    } catch (e) {
      AppLogger.warn('Immediate Gateway claim submission failed. Queued safely offline: $e', tag: 'ClaimRepo');
    }

    return claim;
  }

  @override
  Future<List<InsuranceClaim>> getClaims({String? memberNrc, String? centerCode}) async {
    AppLogger.debug('Fetching claims (nrc: $memberNrc, center: $centerCode)', tag: 'ClaimRepo');
    var result = List<InsuranceClaim>.from(_cachedClaims);

    if (memberNrc != null && memberNrc.isNotEmpty) {
      result = result.where((c) => c.memberNrc == memberNrc).toList();
    }
    if (centerCode != null && centerCode.isNotEmpty) {
      result = result.where((c) => c.centerCode == centerCode).toList();
    }

    return result;
  }
}
