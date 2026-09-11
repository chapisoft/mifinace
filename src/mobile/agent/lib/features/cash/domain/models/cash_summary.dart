import 'package:equatable/equatable.dart';
import 'cash_entry.dart';

/// Real-time summary of field cash held by a credit officer.
class CashSummary extends Equatable {
  final String officerId;
  final double currentCashBalanceMmk;
  final double totalRepaymentMmk;
  final double totalSavingMmk;
  final double safeLimitMmk;
  final bool isExceedingLimit;
  final int transactionCount;
  final List<CashEntry> entries;

  const CashSummary({
    required this.officerId,
    required this.currentCashBalanceMmk,
    required this.totalRepaymentMmk,
    required this.totalSavingMmk,
    required this.safeLimitMmk,
    required this.isExceedingLimit,
    required this.transactionCount,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'officerId': officerId,
      'currentCashBalanceMmk': currentCashBalanceMmk,
      'totalRepaymentMmk': totalRepaymentMmk,
      'totalSavingMmk': totalSavingMmk,
      'safeLimitMmk': safeLimitMmk,
      'isExceedingLimit': isExceedingLimit,
      'transactionCount': transactionCount,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        officerId,
        currentCashBalanceMmk,
        totalRepaymentMmk,
        totalSavingMmk,
        safeLimitMmk,
        isExceedingLimit,
        transactionCount,
        entries,
      ];
}
