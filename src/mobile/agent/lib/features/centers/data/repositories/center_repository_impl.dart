import 'package:drift/drift.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/center_item.dart';
import '../../domain/entities/group_item.dart';
import '../../domain/repositories/center_repository.dart';

/// Implementation of CenterRepository with Offline-First Drift Caching strategy.
class CenterRepositoryImpl implements CenterRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;

  CenterRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase db,
  })  : _apiClient = apiClient,
        _db = db;

  @override
  Future<List<CenterItem>> getCenters({bool forceRefresh = false}) async {
    // 1. Read from local SQLite database
    final localCenters = await _db.getAllCenters();
    if (localCenters.isNotEmpty && !forceRefresh) {
      AppLogger.debug('Returning ${localCenters.length} centers from local SQLite database', tag: 'CenterRepository');
      return localCenters
          .map((c) => CenterItem(
                centerId: c.centerId,
                centerCode: c.centerCode,
                centerName: c.centerName,
                meetingDay: c.meetingDay,
                meetingTime: c.meetingTime,
                townshipCode: c.townshipCode,
                officerId: c.officerId,
              ))
          .toList();
    }

    // 2. Fetch from BFF Gateway if empty or forced refresh
    try {
      AppLogger.info('Fetching centers from BFF Gateway: ${ApiEndpoints.getCenters}', tag: 'CenterRepository');
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getCenters);

      if (response.data != null && response.data!['data'] is List) {
        final list = response.data!['data'] as List<dynamic>;
        final centers = list.map((item) => CenterItem.fromJson(item as Map<String, dynamic>)).toList();

        // Update local database
        final companions = centers
            .map((c) => LocalCentersTableCompanion(
                  centerId: Value(c.centerId),
                  centerCode: Value(c.centerCode),
                  centerName: Value(c.centerName),
                  meetingDay: Value(c.meetingDay),
                  meetingTime: Value(c.meetingTime),
                  townshipCode: Value(c.townshipCode),
                  officerId: Value(c.officerId),
                  updatedAt: Value(DateTime.now()),
                ))
            .toList();

        await _db.insertOrUpdateCenters(companions);
        return centers;
      }
    } catch (e) {
      AppLogger.warn('Network fetch for centers failed, falling back to local cache: $e', tag: 'CenterRepository');
    }

    return localCenters
        .map((c) => CenterItem(
              centerId: c.centerId,
              centerCode: c.centerCode,
              centerName: c.centerName,
              meetingDay: c.meetingDay,
              meetingTime: c.meetingTime,
              townshipCode: c.townshipCode,
              officerId: c.officerId,
            ))
        .toList();
  }

  @override
  Future<List<GroupItem>> getGroupsByCenter(String centerCode, {bool forceRefresh = false}) async {
    final localGroups = await _db.getGroupsByCenter(centerCode);
    if (localGroups.isNotEmpty && !forceRefresh) {
      return localGroups
          .map((g) => GroupItem(
                groupId: g.groupId,
                groupCode: g.groupCode,
                groupName: g.groupName,
                centerCode: g.centerCode,
                leaderName: g.leaderName,
                leaderPhone: g.leaderPhone,
                memberCount: g.memberCount,
              ))
          .toList();
    }

    try {
      final path = ApiEndpoints.getGroups.replaceAll('{centerId}', centerCode);
      AppLogger.info('Fetching groups for center $centerCode from gateway: $path', tag: 'CenterRepository');
      final response = await _apiClient.get<Map<String, dynamic>>(path);

      if (response.data != null && response.data!['data'] is List) {
        final list = response.data!['data'] as List<dynamic>;
        final groups = list.map((item) => GroupItem.fromJson(item as Map<String, dynamic>)).toList();

        final companions = groups
            .map((g) => LocalGroupsTableCompanion(
                  groupId: Value(g.groupId),
                  groupCode: Value(g.groupCode),
                  groupName: Value(g.groupName),
                  centerCode: Value(g.centerCode),
                  leaderName: Value(g.leaderName),
                  leaderPhone: Value(g.leaderPhone),
                  memberCount: Value(g.memberCount),
                  updatedAt: Value(DateTime.now()),
                ))
            .toList();

        await _db.insertOrUpdateGroups(companions);
        return groups;
      }
    } catch (e) {
      AppLogger.warn('Network fetch for groups failed for center $centerCode: $e', tag: 'CenterRepository');
    }

    return localGroups
        .map((g) => GroupItem(
              groupId: g.groupId,
              groupCode: g.groupCode,
              groupName: g.groupName,
              centerCode: g.centerCode,
              leaderName: g.leaderName,
              leaderPhone: g.leaderPhone,
              memberCount: g.memberCount,
            ))
        .toList();
  }
}
