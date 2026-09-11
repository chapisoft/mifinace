import '../entities/center_item.dart';
import '../entities/group_item.dart';

/// Repository interface for Centers and Groups directory.
abstract class CenterRepository {
  Future<List<CenterItem>> getCenters({bool forceRefresh = false});

  Future<List<GroupItem>> getGroupsByCenter(String centerCode, {bool forceRefresh = false});
}
