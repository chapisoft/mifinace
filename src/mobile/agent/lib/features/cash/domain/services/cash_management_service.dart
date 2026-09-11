import '../models/cash_entry.dart';
import '../models/cash_summary.dart';

/// Service interface managing physical field cash and branch handover QR codes.
abstract class CashManagementService {
  /// Computes the real-time cash balance and breakdown for the active officer.
  Future<CashSummary> getCashSummary(String officerId);

  /// Records a cash movement entry (collection, deposit, or handover).
  Future<void> recordCashEntry(CashEntry entry);

  /// Generates a standardized QR handover payload for cashier check-in at the branch.
  Future<String> generateHandoverQrPayload(String officerId);

  /// Completes the cashier handover, zeroing out the active cash balance.
  Future<void> completeHandover(String officerId, String handoverReference);
}
