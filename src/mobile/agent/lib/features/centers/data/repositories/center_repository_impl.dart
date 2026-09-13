import 'package:drift/drift.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/center_item.dart';
import '../../domain/entities/group_item.dart';
import '../../domain/repositories/center_repository.dart';

/// Implementation of CenterRepository with Offline-First Drift Caching and robust auto-seeding.
class CenterRepositoryImpl implements CenterRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;

  CenterRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase db,
  })  : _apiClient = apiClient,
        _db = db;

  List<CenterItem> _getDefaultCenters() {
    return const [
      CenterItem(
        centerId: 'CTR001',
        centerCode: 'CTR-YGN-01',
        centerName: 'Taunggyi Central Center',
        meetingDay: 'MONDAY',
        meetingTime: '09:00 AM',
        townshipCode: 'TAUNGGYI',
        officerId: 'BMF_OFFICER_01',
      ),
      CenterItem(
        centerId: 'CTR002',
        centerCode: 'CTR-YGN-02',
        centerName: 'Ayarwaddy River Center',
        meetingDay: 'TUESDAY',
        meetingTime: '10:30 AM',
        townshipCode: 'TAUNGGYI',
        officerId: 'BMF_OFFICER_01',
      ),
      CenterItem(
        centerId: 'CTR003',
        centerCode: 'CTR-YGN-03',
        centerName: 'Inle Lake Solidarity Center',
        meetingDay: 'WEDNESDAY',
        meetingTime: '02:00 PM',
        townshipCode: 'NYAUNGSHWE',
        officerId: 'BMF_OFFICER_01',
      ),
    ];
  }

  List<GroupItem> _getDefaultGroups(String centerCode) {
    const all = [
      GroupItem(
        groupId: 'GRP001',
        groupCode: 'GRP-YGN-01',
        groupName: 'Solidarity Group 1 (Women Agri)',
        centerCode: 'CTR-YGN-01',
        leaderName: 'Daw Khin Myint',
        leaderPhone: '09123456789',
        memberCount: 5,
      ),
      GroupItem(
        groupId: 'GRP002',
        groupCode: 'GRP-YGN-02',
        groupName: 'Solidarity Group 2 (Market Vendors)',
        centerCode: 'CTR-YGN-01',
        leaderName: 'Daw Nilar Myint',
        leaderPhone: '09876543210',
        memberCount: 5,
      ),
      GroupItem(
        groupId: 'GRP003',
        groupCode: 'GRP-YGN-03',
        groupName: 'River Farmers Group A',
        centerCode: 'CTR-YGN-02',
        leaderName: 'U Thant Zin',
        leaderPhone: '09234567890',
        memberCount: 5,
      ),
    ];

    if (centerCode == 'C001' || centerCode == 'CTR-YGN-01') {
      return all.where((g) => g.centerCode == 'CTR-YGN-01').toList();
    }
    final filtered = all.where((g) => g.centerCode.toUpperCase() == centerCode.toUpperCase()).toList();
    return filtered.isNotEmpty ? filtered : all.take(2).toList();
  }

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
      AppLogger.warn('Network fetch for centers failed, falling back to seed/local cache: $e', tag: 'CenterRepository');
    }

    if (localCenters.isNotEmpty) {
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

    // Auto-seed initial centers into local encrypted SQLite database
    final defaults = _getDefaultCenters();
    final companions = defaults
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
    return defaults;
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

    if (localGroups.isNotEmpty) {
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

    // Auto-seed initial groups into local encrypted SQLite database
    final defaults = _getDefaultGroups(centerCode);
    final companions = defaults
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
    return defaults;
  }
}
