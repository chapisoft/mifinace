import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';

/// Streamlined Dynamic Quick Actions Shortcut Bar on Member Home Screen.
class QuickActionsRow extends StatelessWidget {
  final List<String> activeShortcuts;
  final VoidCallback onApplyLoan;
  final VoidCallback onSavings;
  final VoidCallback onInsurance;
  final VoidCallback onBranches;
  final VoidCallback onScanQr;
  final VoidCallback onLoans;
  final VoidCallback onHistory;
  final VoidCallback? onCustomize;

  const QuickActionsRow({
    super.key,
    this.activeShortcuts = const ['APPLY_LOAN', 'SAVINGS', 'INSURANCE', 'BRANCHES'],
    required this.onApplyLoan,
    required this.onSavings,
    required this.onInsurance,
    required this.onBranches,
    required this.onScanQr,
    required this.onLoans,
    required this.onHistory,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final displayedShortcuts = activeShortcuts.isEmpty
        ? ['APPLY_LOAN', 'SAVINGS', 'INSURANCE', 'BRANCHES']
        : activeShortcuts.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomerTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CustomerTheme.primaryNavy.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: CustomerTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.quickActions,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: CustomerTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (onCustomize != null)
                  InkWell(
                    onTap: onCustomize,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.customize,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: CustomerTheme.primaryCyan,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.tune_rounded,
                            size: 13,
                            color: CustomerTheme.primaryCyan,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayedShortcuts.map((key) {
              return _buildShortcutItem(context, key, l10n);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(BuildContext context, String key, CustomerLocalizations l10n) {
    switch (key) {
      case 'APPLY_LOAN':
        return _buildActionItem(
          icon: Icons.app_registration_rounded,
          label: l10n.menuApplyLoanTitle,
          color: CustomerTheme.primaryCyan,
          onTap: onApplyLoan,
        );
      case 'SAVINGS':
        return _buildActionItem(
          icon: Icons.savings_outlined,
          label: l10n.menuSavingsTitle,
          color: CustomerTheme.statusCurrent,
          onTap: onSavings,
        );
      case 'INSURANCE':
        return _buildActionItem(
          icon: Icons.health_and_safety_outlined,
          label: l10n.menuInsuranceTitle,
          color: CustomerTheme.accentCrimson,
          onTap: onInsurance,
        );
      case 'BRANCHES':
        return _buildActionItem(
          icon: Icons.location_on_outlined,
          label: l10n.menuBranchesTitle,
          color: const Color(0xFF6366F1),
          onTap: onBranches,
        );
      case 'SCAN_QR':
        return _buildActionItem(
          icon: Icons.qr_code_scanner_rounded,
          label: l10n.navScanQr,
          color: const Color(0xFF0D9488),
          onTap: onScanQr,
        );
      case 'LOANS':
        return _buildActionItem(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.menuLoansTitle,
          color: const Color(0xFFF59E0B),
          onTap: onLoans,
        );
      case 'HISTORY':
        return _buildActionItem(
          icon: Icons.receipt_long_outlined,
          label: l10n.navHistory,
          color: const Color(0xFF8B5CF6),
          onTap: onHistory,
        );
      default:
        return _buildActionItem(
          icon: Icons.apps_rounded,
          label: key,
          color: CustomerTheme.textSecondary,
          onTap: () {},
        );
    }
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withAlpha(40), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CustomerTheme.textPrimary,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
