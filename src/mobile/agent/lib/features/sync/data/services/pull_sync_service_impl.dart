import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/services/pull_sync_service.dart';

/// Implementation of [PullSyncService] pulling delta updates from Backend BFF Gateway.
class PullSyncServiceImpl implements PullSyncService {
  final ApiClient _apiClient;
  final AppDatabase _database;

  PullSyncServiceImpl({
    required ApiClient apiClient,
    required AppDatabase database,
  })  : _apiClient = apiClient,
        _database = database;

  @override
  Future<int> pullCatalogDelta({DateTime? since}) async {
    AppLogger.info('Initiating delta catalog pull from Backend BFF Gateway...', tag: 'PullSyncService');

    try {
      final response = await _apiClient.get(
        '/api/v1/mobile/catalog/pull',
        queryParameters: since != null ? {'since': since.toIso8601String()} : null,
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        AppLogger.warn('Server returned empty catalog data payload.', tag: 'PullSyncService');
        return 0;
      }

      int totalUpdated = 0;

      // 1. Process Centers
      if (data['centers'] != null && data['centers'] is List) {
        final centersList = data['centers'] as List<dynamic>;
        final companions = centersList.map<LocalCentersTableCompanion>((item) {
          return LocalCentersTableCompanion(
            centerId: Value(item['centerId']?.toString() ?? item['id']?.toString() ?? ''),
            centerCode: Value(item['centerCode']?.toString() ?? ''),
            centerName: Value(item['centerName']?.toString() ?? ''),
            meetingDay: Value(item['meetingDay']?.toString() ?? ''),
            meetingTime: Value(item['meetingTime']?.toString() ?? ''),
            townshipCode: Value(item['townshipCode']?.toString() ?? ''),
            officerId: Value(item['officerId']?.toString() ?? ''),
            updatedAt: Value(DateTime.now()),
          );
        }).toList();

        await _database.insertOrUpdateCenters(companions);
        totalUpdated += companions.length;
      }

      // 2. Process Groups
      if (data['groups'] != null && data['groups'] is List) {
        final groupsList = data['groups'] as List<dynamic>;
        final companions = groupsList.map<LocalGroupsTableCompanion>((item) {
          return LocalGroupsTableCompanion(
            groupId: Value(item['groupId']?.toString() ?? item['id']?.toString() ?? ''),
            groupCode: Value(item['groupCode']?.toString() ?? ''),
            groupName: Value(item['groupName']?.toString() ?? ''),
            centerCode: Value(item['centerCode']?.toString() ?? ''),
            leaderName: Value(item['leaderName']?.toString() ?? ''),
            leaderPhone: Value(item['leaderPhone']?.toString() ?? ''),
            memberCount: Value(int.tryParse(item['memberCount']?.toString() ?? '0') ?? 0),
            updatedAt: Value(DateTime.now()),
          );
        }).toList();

        await _database.insertOrUpdateGroups(companions);
        totalUpdated += companions.length;
      }

      // 3. Process Schedules
      if (data['schedules'] != null && data['schedules'] is List) {
        final schedulesList = data['schedules'] as List<dynamic>;
        final companions = schedulesList.map<LocalSchedulesTableCompanion>((item) {
          final dueDate = DateTime.tryParse(item['dueDate']?.toString() ?? '') ?? DateTime.now();
          return LocalSchedulesTableCompanion(
            scheduleId: Value(item['scheduleId']?.toString() ?? item['id']?.toString() ?? ''),
            contractCode: Value(item['contractCode']?.toString() ?? ''),
            customerCode: Value(item['customerCode']?.toString() ?? ''),
            customerName: Value(item['customerName']?.toString() ?? ''),
            groupCode: Value(item['groupCode']?.toString() ?? ''),
            periodNumber: Value(int.tryParse(item['periodNumber']?.toString() ?? '1') ?? 1),
            principalAmount: Value(double.tryParse(item['principalAmount']?.toString() ?? '0') ?? 0.0),
            interestAmount: Value(double.tryParse(item['interestAmount']?.toString() ?? '0') ?? 0.0),
            insuranceFee: Value(double.tryParse(item['insuranceFee']?.toString() ?? '0') ?? 0.0),
            compulsorySaving: Value(double.tryParse(item['compulsorySaving']?.toString() ?? '0') ?? 0.0),
            totalAmount: Value(double.tryParse(item['totalAmount']?.toString() ?? '0') ?? 0.0),
            dueDate: Value(dueDate),
            status: Value(item['status']?.toString() ?? 'PENDING'),
            debtGroup: Value(item['debtGroup']?.toString() ?? 'STANDARD'),
            updatedAt: Value(DateTime.now()),
          );
        }).toList();

        await _database.insertOrUpdateSchedules(companions);
        totalUpdated += companions.length;
      }

      AppLogger.info('Successfully pulled and updated $totalUpdated records from server.', tag: 'PullSyncService');
      return totalUpdated;
    } catch (e, stack) {
      AppLogger.error('Pull catalog sync failed: $e', tag: 'PullSyncService', stackTrace: stack);
      return 0;
    }
  }
}
