import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../../domain/models/customer_saving_account.dart';

/// Card widget displaying an individual savings passbook with balance and daily accrued interest.
class SavingCard extends StatelessWidget {
  final CustomerSavingAccount account;

  const SavingCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    Color badgeColor;
    String typeLabel;
    switch (account.savingType) {
      case SavingType.compulsory:
        badgeColor = CustomerTheme.primaryNavy;
        typeLabel = l10n.compulsorySaving;
        break;
      case SavingType.voluntary:
        badgeColor = const Color(0xFF0D9488);
        typeLabel = l10n.voluntarySaving;
        break;
      case SavingType.fixedTerm:
        badgeColor = CustomerTheme.secondaryAmber;
        typeLabel = l10n.fixedTermSaving;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
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
                        typeLabel,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${account.accountNumber}',
                        style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    '${account.interestRateAnnual}%',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: badgeColor),
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
                    Text(l10n.depositPrincipal, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatMmk(account.balanceMmk),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.accruedProfitYield, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      '+${CurrencyFormatter.formatMmk(account.accruedInterestMmk)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.statusCurrent),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${account.openedDate.day}/${account.openedDate.month}/${account.openedDate.year}',
                  style: const TextStyle(fontSize: 10.5, color: CustomerTheme.textSecondary),
                ),
                if (account.maturityDate != null)
                  Text(
                    '${l10n.dueDate}: ${account.maturityDate!.day}/${account.maturityDate!.month}/${account.maturityDate!.year}',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: CustomerTheme.secondaryAmber),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
