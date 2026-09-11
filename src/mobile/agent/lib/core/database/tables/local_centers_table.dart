import 'package:drift/drift.dart';

/// Local table caching Centers (Cụm) for offline access.
@DataClassName('LocalCenter')
class LocalCentersTable extends Table {
  TextColumn get centerId => text().named('center_id')();
  TextColumn get centerCode => text().named('center_code')();
  TextColumn get centerName => text().named('center_name')();
  TextColumn get meetingDay => text().named('meeting_day')();
  TextColumn get meetingTime => text().named('meeting_time')();
  TextColumn get townshipCode => text().named('township_code')();
  TextColumn get officerId => text().named('officer_id')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {centerId};
}
