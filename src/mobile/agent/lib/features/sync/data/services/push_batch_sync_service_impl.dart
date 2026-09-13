import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/services/push_batch_sync_service.dart';

/// Implementation of [PushBatchSyncService] for pushing offline repayments to Backend BFF Gateway in atomic batches.
class PushBatchSyncServiceImpl implements PushBatchSyncService {
  final ApiClient _apiClient;
  final AppDatabase _database;

  PushBatchSyncServiceImpl({
    required ApiClient apiClient,
    required AppDatabase database,
  })  : _apiClient = apiClient,
        _database = database;

  @override
  Future<int> pushPendingRepayments({int batchSize = 50}) async {
    final pendingItems = await _database.getPendingSyncQueueItems(limit: batchSize);
    if (pendingItems.isEmpty) {
      AppLogger.debug('No pending repayments in local sync queue.', tag: 'PushBatchSyncService');
      return 0;
    }

    AppLogger.info('Found ${pendingItems.length} pending repayments. Preparing push batch...', tag: 'PushBatchSyncService');

    int successCount = 0;

    final List<Map<String, dynamic>> batchPayload = [];
    for (final item in pendingItems) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(item.payloadJson) as Map);
        decoded['queueId'] = item.queueId;
        decoded['idempotencyKey'] = item.idempotencyKey;
        batchPayload.add(decoded);
      } catch (e) {
        AppLogger.error('Malformed payload JSON for queue item: ${item.queueId}', tag: 'PushBatchSyncService');
        await _database.updateSyncQueueStatus(item.queueId, SyncStatus.failed, errorMessage: 'Malformed JSON payload');
      }
    }

    if (batchPayload.isEmpty) return 0;

    try {
      final response = await _apiClient.post(
        '/api/v1/mobile/sync/push',
        data: {
          'batchSize': batchPayload.length,
          'transactions': batchPayload,
        },
      );

      final data = response.data;
      if (data != null && data['results'] is List) {
        final results = data['results'] as List<dynamic>;
        for (final res in results) {
          final String queueId = res['queueId']?.toString() ?? '';
          final syncStatus = SyncStatus.fromCode(res['status']?.toString());
          final String? serverRef = res['serverRefId']?.toString();
          final String? errorMsg = res['errorMessage']?.toString();

          if (syncStatus == SyncStatus.completed) {
            AppLogger.info('Queue item $queueId synced successfully (ref: $serverRef)', tag: 'BatchSync');
            await _database.updateSyncQueueStatus(queueId, SyncStatus.completed);
            successCount++;

            // Update matching repayment and schedule status in local DB
            final matchingItem = pendingItems.firstWhere((p) => p.queueId == queueId);
            await (_database.update(_database.localRepaymentsTable)
                  ..where((t) => t.transactionId.equals(matchingItem.aggregateId)))
                .write(
              LocalRepaymentsTableCompanion(
                syncStatus: Value(SyncStatus.completed.code),
                syncedAt: Value(DateTime.now()),
              ),
            );
          } else {
            await _database.updateSyncQueueStatus(queueId, SyncStatus.failed, errorMessage: errorMsg ?? 'Server rejected transaction');
          }
        }
      } else {
        // Entire batch accepted
        for (final item in pendingItems) {
          await _database.updateSyncQueueStatus(item.queueId, SyncStatus.completed);
          successCount++;
        }
      }

      AppLogger.info('Push batch completed: $successCount / ${pendingItems.length} transactions synced.', tag: 'PushBatchSyncService');
      return successCount;
    } catch (e, stack) {
      AppLogger.error('Failed to push repayment batch to Gateway: $e', tag: 'PushBatchSyncService', stackTrace: stack);
      return 0;
    }
  }
}
