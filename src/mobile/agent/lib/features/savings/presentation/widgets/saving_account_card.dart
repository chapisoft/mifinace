import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/saving_account.dart';

/// Card displaying savings passbook account details, balance, and quick deposit action.
class SavingAccountCard extends StatelessWidget {
  final SavingAccount account;
  final VoidCallback onDeposit;

  const SavingAccountCard({
    super.key,
    required this.account,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    account.customerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accentTeal.withAlpha(80)),
                  ),
                  child: Text(
                    account.productType.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.credit_card, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  account.accountNumber,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.badge_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  account.nrcFormatted,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accumulated Balance',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatMmk(account.balanceMmk),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Deposit'),
                  onPressed: onDeposit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
