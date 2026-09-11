import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: loan.isDueSoon ? CustomerTheme.secondaryAmber : CustomerTheme.borderSubtle,
          width: loan.isDueSoon ? 2 : 1,
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Contract: ${loan.contractCode}',
                        style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    const Text('Total Loan Principal', style: TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
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
                    const Text('Remaining Principal', style: TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
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

            // Progress Bar (Repaid Principal %)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: loan.completionProgress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  loan.debtGroup.isNonPerforming ? CustomerTheme.accentCrimson : CustomerTheme.primaryNavy,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(loan.completionProgress * 100).toStringAsFixed(0)}% Repaid',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CustomerTheme.textSecondary),
                ),
                Text(
                  '${loan.paidPeriods} / ${loan.totalPeriods} Months',
                  style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                ),
              ],
            ),

            // Due Soon Alert Banner within card
            if (loan.isDueSoon) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CustomerTheme.secondaryAmber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Repayment due: ${CurrencyFormatter.formatMmk(loan.nextDueAmountMmk)} (${loan.daysUntilDue} days left)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewSchedule,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomerTheme.primaryNavy,
                      side: const BorderSide(color: CustomerTheme.primaryNavy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('View Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Pay Installment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
