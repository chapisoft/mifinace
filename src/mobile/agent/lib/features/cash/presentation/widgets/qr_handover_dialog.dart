import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/cash_summary.dart';

/// Dialog displaying cashier handover QR payload and breakdown for vault deposit.
class QrHandoverDialog extends StatelessWidget {
  final CashSummary summary;
  final String qrPayload;
  final VoidCallback onHandoverConfirmed;

  const QrHandoverDialog({
    super.key,
    required this.summary,
    required this.qrPayload,
    required this.onHandoverConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.qr_code_2, color: AppTheme.primaryNavy, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.branchCashierHandoverTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // QR Placeholder Box with high contrast pattern
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryNavy, width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 80, color: AppTheme.primaryNavy),
                        SizedBox(height: 8),
                        Text(
                          'BMF VAULT QR',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyFormatter.formatMmk(summary.currentCashBalanceMmk),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.transactionCount} ${l10n.transactionsCollectedToday}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.loanRepayments}:', style: const TextStyle(fontSize: 12)),
                      Text(CurrencyFormatter.formatMmk(summary.totalRepaymentMmk),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.savingsDeposits}:', style: const TextStyle(fontSize: 12)),
                      Text(CurrencyFormatter.formatMmk(summary.totalSavingMmk),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.closeButton),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentTeal,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.check, size: 18),
          label: Text(l10n.confirmCashierDeposit),
          onPressed: () {
            Navigator.of(context).pop();
            onHandoverConfirmed();
          },
        ),
      ],
    );
  }
}
