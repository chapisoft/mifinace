import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../../domain/models/customer_saving_account.dart';

/// Card widget displaying an individual savings passbook with balance and daily accrued interest.
class SavingCard extends StatelessWidget {
  final CustomerSavingAccount account;

  const SavingCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (account.savingType) {
      case SavingType.compulsory:
        badgeColor = CustomerTheme.primaryNavy;
        break;
      case SavingType.voluntary:
        badgeColor = const Color(0xFF0D9488); // Teal
        break;
      case SavingType.fixedTerm:
        badgeColor = CustomerTheme.secondaryAmber;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CustomerTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Type & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.savingType.label,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Account: ${account.accountNumber}',
                        style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    '${account.interestRateAnnual}% p.a.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Figures: Principal & Accrued Interest
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deposit Principal', style: TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatMmk(account.balanceMmk),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Accrued Profit Yield', style: TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      '+${CurrencyFormatter.formatMmk(account.accruedInterestMmk)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.statusCurrent),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Footer: Maturity info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opened: ${account.openedDate.day}/${account.openedDate.month}/${account.openedDate.year}',
                  style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                ),
                if (account.maturityDate != null)
                  Text(
                    'Maturity: ${account.maturityDate!.day}/${account.maturityDate!.month}/${account.maturityDate!.year}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CustomerTheme.secondaryAmber),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
