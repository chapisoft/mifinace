import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';

/// Card widget displaying active borrower loan summary with progress bar and due alert.
class LoanCard extends StatelessWidget {
  final CustomerLoan loan;
  final VoidCallback onViewSchedule;
  final VoidCallback onPayNow;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onViewSchedule,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: loan.isDueSoon ? CustomerTheme.secondaryAmber : CustomerTheme.borderSubtle,
          width: loan.isDueSoon ? 1.8 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Loan Type & Debt Group Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.loanType.label,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.contractCodeLabel}: ${loan.contractCode}',
                        style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: loan.debtGroup.badgeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: loan.debtGroup.badgeColor),
                  ),
                  child: Text(
                    loan.debtGroup.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: loan.debtGroup.badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Financial Figures
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.principal, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatMmk(loan.disbursedAmountMmk),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.outstandingLoanMetric, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatMmk(loan.remainingPrincipalMmk),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.secondaryAmber),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: loan.completionProgress,
                minHeight: 6,
                backgroundColor: CustomerTheme.backgroundLight,
                valueColor: const AlwaysStoppedAnimation<Color>(CustomerTheme.statusCurrent),
              ),
            ),
            const SizedBox(height: 12),

            // Actions: View Schedule & Pay Now
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewSchedule,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomerTheme.primaryNavy,
                      side: const BorderSide(color: CustomerTheme.primaryNavy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(l10n.scheduleTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primaryCyan,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(l10n.payNow, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
