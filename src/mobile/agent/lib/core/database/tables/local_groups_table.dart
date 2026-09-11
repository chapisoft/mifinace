import 'package:drift/drift.dart';

/// Local table caching Groups (Tổ) for offline access.
@DataClassName('LocalGroup')
class LocalGroupsTable extends Table {
  TextColumn get groupId => text().named('group_id')();
  TextColumn get groupCode => text().named('group_code')();
  TextColumn get groupName => text().named('group_name')();
  TextColumn get centerCode => text().named('center_code')();
  TextColumn get leaderName => text().named('leader_name').nullable()();
  TextColumn get leaderPhone => text().named('leader_phone').nullable()();
  IntColumn get memberCount => integer().named('member_count').withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {groupId};
}
