import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';

/// 4-column Grid Menu Widget for Customer Dashboard (4 menu items per row).
/// Clean modern fintech style with balanced icon containers and responsive labels.
class QuickServicesGrid extends StatelessWidget {
  final VoidCallback onMmqrPay;
  final VoidCallback onLoans;
  final VoidCallback onSavings;
  final VoidCallback onInsurance;
  final VoidCallback onApplyLoan;
  final VoidCallback onHistory;
  final VoidCallback onBranches;
  final VoidCallback onNotifications;
  final int unreadNotificationsCount;

  const QuickServicesGrid({
    super.key,
    required this.onMmqrPay,
    required this.onLoans,
    required this.onSavings,
    required this.onInsurance,
    required this.onApplyLoan,
    required this.onHistory,
    required this.onBranches,
    required this.onNotifications,
    this.unreadNotificationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomerTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CustomerTheme.primaryNavy.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        size: 14,
                        color: CustomerTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.quickServices,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: CustomerTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Row 1: 4 Items
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGridItem(
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.menuMmqrTitle,
                color: CustomerTheme.secondaryAmber,
                onTap: onMmqrPay,
              ),
              _buildGridItem(
                icon: Icons.calendar_month_outlined,
                label: l10n.menuLoansTitle,
                color: CustomerTheme.primaryNavy,
                onTap: onLoans,
              ),
              _buildGridItem(
                icon: Icons.savings_outlined,
                label: l10n.menuSavingsTitle,
                color: CustomerTheme.statusCurrent,
                onTap: onSavings,
              ),
              _buildGridItem(
                icon: Icons.health_and_safety_outlined,
                label: l10n.menuInsuranceTitle,
                color: CustomerTheme.accentCrimson,
                onTap: onInsurance,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: 4 Items
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGridItem(
                icon: Icons.app_registration_rounded,
                label: l10n.menuApplyLoanTitle,
                color: CustomerTheme.primaryCyan,
                onTap: onApplyLoan,
              ),
              _buildGridItem(
                icon: Icons.receipt_long_outlined,
                label: l10n.menuHistoryTitle,
                color: CustomerTheme.accentTeal,
                onTap: onHistory,
              ),
              _buildGridItem(
                icon: Icons.location_on_outlined,
                label: l10n.menuBranchesTitle,
                color: const Color(0xFF6366F1),
                onTap: onBranches,
              ),
              _buildGridItem(
                icon: Icons.notifications_none_rounded,
                label: l10n.menuNotificationsTitle,
                color: const Color(0xFF3B82F6),
                badgeCount: unreadNotificationsCount,
                onTap: onNotifications,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withAlpha(22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withAlpha(45), width: 1),
                      ),
                      child: Icon(icon, color: color, size: 23),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: CustomerTheme.accentCrimson,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            badgeCount > 9 ? '9+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CustomerTheme.textPrimary,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
