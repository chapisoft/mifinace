import 'package:drift/drift.dart';

/// Local table caching Member Loan Schedules (Lịch thu nợ) for offline field collection.
@DataClassName('LocalSchedule')
class LocalSchedulesTable extends Table {
  TextColumn get scheduleId => text().named('schedule_id')();
  TextColumn get contractCode => text().named('contract_code')();
  TextColumn get customerCode => text().named('customer_code')();
  TextColumn get customerName => text().named('customer_name')();
  TextColumn get groupCode => text().named('group_code')();
  IntColumn get periodNumber => integer().named('period_number')();
  RealColumn get principalAmount => real().named('principal_amount')();
  RealColumn get interestAmount => real().named('interest_amount')();
  RealColumn get insuranceFee => real().named('insurance_fee')();
  RealColumn get compulsorySaving => real().named('compulsory_saving')();
  RealColumn get totalAmount => real().named('total_amount')();
  DateTimeColumn get dueDate => dateTime().named('due_date')();
  TextColumn get status => text().named('status')(); // PENDING, PAID_LOCAL, SETTLED, OVERDUE
  TextColumn get debtGroup => text().named('debt_group')(); // STANDARD, WATCH, SUBSTANDARD, DOUBTFUL, LOSS
  RealColumn get collectedAmount => real().named('collected_amount').nullable()();
  DateTimeColumn get collectedAt => dateTime().named('collected_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {scheduleId};
}
