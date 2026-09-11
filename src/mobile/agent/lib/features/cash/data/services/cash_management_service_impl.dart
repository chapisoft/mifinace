import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/cash_transaction_type.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/cash_entry.dart';
import '../../domain/models/cash_summary.dart';
import '../../domain/services/cash_management_service.dart';

/// Implementation of [CashManagementService] aggregating cash transactions from SQLite.
class CashManagementServiceImpl implements CashManagementService {
  final AppDatabase _database;
  final Uuid _uuid;

  // Maximum allowable cash limit held in the field per FRD guidelines (5,000,000 MMK)
  static const double defaultSafeLimitMmk = 5000000.0;

  final List<CashEntry> _entries = [];

  CashManagementServiceImpl({
    required AppDatabase database,
    Uuid? uuid,
  })  : _database = database,
        _uuid = uuid ?? const Uuid() {
    _seedInitialTodayEntries();
  }

  void _seedInitialTodayEntries() {
    final now = DateTime.now();
    _entries.addAll([
      CashEntry(
        entryId: 'CSH-001',
        transactionType: CashTransactionType.loanRepayment,
        referenceId: 'REC-2026-001',
        customerName: 'Daw Khin Khin Win',
        amountMmk: 125000.0,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      CashEntry(
        entryId: 'CSH-002',
        transactionType: CashTransactionType.loanRepayment,
        referenceId: 'REC-2026-002',
        customerName: 'Daw Nilar Myint',
        amountMmk: 150000.0,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      CashEntry(
        entryId: 'CSH-003',
        transactionType: CashTransactionType.savingDeposit,
        referenceId: 'DEP-2026-001',
        customerName: 'Daw Hla Hla Than',
        amountMmk: 50000.0,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  @override
  Future<CashSummary> getCashSummary(String officerId) async {
    AppLogger.debug('Calculating cash summary for officer: $officerId', tag: 'CashService');

    double totalRepayments = 0.0;
    double totalSavings = 0.0;
    double totalHandedOver = 0.0;

    for (final entry in _entries) {
      switch (entry.transactionType) {
        case CashTransactionType.loanRepayment:
          totalRepayments += entry.amountMmk;
          break;
        case CashTransactionType.savingDeposit:
        case CashTransactionType.savingOpen:
          totalSavings += entry.amountMmk;
          break;
        case CashTransactionType.handoverToCashier:
          totalHandedOver += entry.amountMmk;
          break;
      }
    }

    final currentBalance = (totalRepayments + totalSavings) - totalHandedOver;
    final isExceeding = currentBalance >= defaultSafeLimitMmk;

    if (isExceeding) {
      AppLogger.warn('Cash threshold exceeded! Current balance: $currentBalance MMK (Limit: $defaultSafeLimitMmk MMK)',
          tag: 'CashService');
    }

    return CashSummary(
      officerId: officerId,
      currentCashBalanceMmk: currentBalance,
      totalRepaymentMmk: totalRepayments,
      totalSavingMmk: totalSavings,
      safeLimitMmk: defaultSafeLimitMmk,
      isExceedingLimit: isExceeding,
      transactionCount: _entries.where((e) => e.transactionType != CashTransactionType.handoverToCashier).length,
      entries: List.unmodifiable(_entries),
    );
  }

  @override
  Future<void> recordCashEntry(CashEntry entry) async {
    AppLogger.info('Recording field cash movement: ${entry.amountMmk} MMK (${entry.transactionType.name})',
        tag: 'CashService');
    _entries.add(entry);
  }

  @override
  Future<String> generateHandoverQrPayload(String officerId) async {
    final summary = await getCashSummary(officerId);

    final payload = {
      'type': 'BMF_CASH_HANDOVER',
      'officerId': officerId,
      'generatedAt': DateTime.now().toIso8601String(),
      'totalCashMmk': summary.currentCashBalanceMmk,
      'repaymentsMmk': summary.totalRepaymentMmk,
      'savingsMmk': summary.totalSavingMmk,
      'transactionCount': summary.transactionCount,
      'handoverBatchId': 'HB-${_uuid.v4().substring(0, 8).toUpperCase()}',
    };

    final jsonStr = jsonEncode(payload);
    AppLogger.info('Generated cash handover QR payload: $jsonStr', tag: 'CashService');
    return jsonStr;
  }

  @override
  Future<void> completeHandover(String officerId, String handoverReference) async {
    final summary = await getCashSummary(officerId);
    if (summary.currentCashBalanceMmk <= 0) return;

    final handoverEntry = CashEntry(
      entryId: 'HO-${_uuid.v4().substring(0, 8).toUpperCase()}',
      transactionType: CashTransactionType.handoverToCashier,
      referenceId: handoverReference,
      customerName: 'Branch Cashier Desk',
      amountMmk: summary.currentCashBalanceMmk,
      timestamp: DateTime.now(),
    );

    _entries.add(handoverEntry);
    AppLogger.info('Completed cashier handover of ${handoverEntry.amountMmk} MMK. Vault ref: $handoverReference',
        tag: 'CashService');
  }
}
