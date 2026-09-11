import 'package:drift/drift.dart';

/// Local table storing collected repayment receipts before/after synchronization.
@DataClassName('LocalRepayment')
class LocalRepaymentsTable extends Table {
  TextColumn get transactionId => text().named('transaction_id')();
  TextColumn get contractCode => text().named('contract_code')();
  IntColumn get periodNumber => integer().named('period_number')();
  TextColumn get customerCode => text().named('customer_code')();
  RealColumn get principalAmount => real().named('principal_amount')();
  RealColumn get interestAmount => real().named('interest_amount')();
  RealColumn get insuranceFee => real().named('insurance_fee')();
  RealColumn get compulsorySaving => real().named('compulsory_saving')();
  RealColumn get totalAmount => real().named('total_amount')();
  TextColumn get paymentMethod => text().named('payment_method')(); // CASH, MMQR, etc.
  TextColumn get receiptNumber => text().named('receipt_number')();
  TextColumn get collectorId => text().named('collector_id')();
  DateTimeColumn get collectedAt => dateTime().named('collected_at')();
  TextColumn get syncStatus => text().named('sync_status')(); // PENDING, SYNCED, FAILED
  TextColumn get idempotencyKey => text().named('idempotency_key')();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();
  TextColumn get errorMessage => text().named('error_message').nullable()();

  @override
  Set<Column> get primaryKey => {transactionId};
}
