import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Streamlined 1-row Dynamic Quick Actions Shortcut Bar on Field Officer Dashboard.
/// Provides instant 1-tap access to primary field workflows with customizable modal.
class AgentQuickActionsRow extends StatelessWidget {
  final List<String> activeShortcuts;
  final VoidCallback onCollection;
  final VoidCallback onNewLoan;
  final VoidCallback onSavings;
  final VoidCallback onCenters;
  final VoidCallback? onCash;
  final VoidCallback? onInsurance;
  final VoidCallback? onPrinter;
  final VoidCallback? onSync;
  final VoidCallback onCustomize;

  const AgentQuickActionsRow({
    super.key,
    this.activeShortcuts = const ['COLLECTION', 'NEW_LOAN', 'SAVINGS', 'CENTERS'],
    required this.onCollection,
    required this.onNewLoan,
    required this.onSavings,
    required this.onCenters,
    this.onCash,
    this.onInsurance,
    this.onPrinter,
    this.onSync,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayedShortcuts = activeShortcuts.isEmpty
        ? ['COLLECTION', 'NEW_LOAN', 'SAVINGS', 'CENTERS']
        : activeShortcuts.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.quickActions,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onCustomize,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.customize,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentEmerald,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.tune_rounded, size: 12, color: AppTheme.accentEmerald),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 1 Single Row of 4 items
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

  Widget _buildShortcutItem(BuildContext context, String key, AppLocalizations l10n) {
    switch (key) {
      case 'COLLECTION':
        return _buildActionItem(
          icon: Icons.assignment_turned_in_outlined,
          label: l10n.actionCollectRepayment,
          color: AppTheme.accentEmerald,
          onTap: onCollection,
        );
      case 'NEW_LOAN':
        return _buildActionItem(
          icon: Icons.app_registration_rounded,
          label: l10n.actionNewLoan,
          color: AppTheme.primaryNavy,
          onTap: onNewLoan,
        );
      case 'SAVINGS':
        return _buildActionItem(
          icon: Icons.savings_outlined,
          label: l10n.actionSavings,
          color: AppTheme.accentTeal,
          onTap: onSavings,
        );
      case 'CENTERS':
        return _buildActionItem(
          icon: Icons.groups_outlined,
          label: l10n.actionCenters,
          color: AppTheme.accentOrange,
          onTap: onCenters,
        );
      case 'CASH':
        return _buildActionItem(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.actionManageCash,
          color: const Color(0xFF6366F1),
          onTap: onCash ?? () {},
        );
      case 'INSURANCE':
        return _buildActionItem(
          icon: Icons.health_and_safety_outlined,
          label: l10n.actionInsurance,
          color: AppTheme.accentCrimson,
          onTap: onInsurance ?? () {},
        );
      case 'PRINTER':
        return _buildActionItem(
          icon: Icons.print_outlined,
          label: l10n.actionPrinter,
          color: const Color(0xFF0D9488),
          onTap: onPrinter ?? () {},
        );
      case 'SYNC':
        return _buildActionItem(
          icon: Icons.sync_rounded,
          label: l10n.actionSync,
          color: const Color(0xFFF59E0B),
          onTap: onSync ?? () {},
        );
      default:
        return _buildActionItem(
          icon: Icons.apps_rounded,
          label: key,
          color: AppTheme.textSecondary,
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
                    color: AppTheme.textPrimary,
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
