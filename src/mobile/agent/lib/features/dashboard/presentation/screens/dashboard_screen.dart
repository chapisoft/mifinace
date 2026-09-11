import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Main Dashboard Screen for Credit Officers in the field.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: l10n.syncNow,
            onPressed: () {
              context.push(AppRouter.syncRoute);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: () => context.go(AppRouter.loginRoute),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Network Status Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentTeal.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi, color: AppTheme.accentTeal, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.networkOnline,
                      style: const TextStyle(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Target & Collection Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todayTarget,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricBox(
                            label: l10n.todayTarget,
                            value: CurrencyFormatter.formatMmk(1250000),
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricBox(
                            label: l10n.collectedAmount,
                            value: CurrencyFormatter.formatMmk(850000),
                            color: AppTheme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricBox(
                            label: l10n.remainingAmount,
                            value: CurrencyFormatter.formatMmk(400000),
                            color: AppTheme.accentAmber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricBox(
                            label: l10n.syncPending,
                            value: '0',
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Quick Field Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            // Action Buttons List
            _ActionTile(
              icon: Icons.app_registration_outlined,
              title: 'New Loan Application',
              subtitle: 'KYC NRC scan, GPS residence survey & e-Signature',
              color: AppTheme.primaryNavy,
              onTap: () {
                context.push(AppRouter.loanApplyRoute);
              },
            ),
            _ActionTile(
              icon: Icons.groups_outlined,
              title: l10n.centersTitle,
              subtitle: 'View scheduled village meeting centers',
              color: AppTheme.primaryNavy,
              onTap: () {
                context.push(AppRouter.centersRoute);
              },
            ),
            _ActionTile(
              icon: Icons.assignment_outlined,
              title: l10n.collectionSheetTitle,
              subtitle: 'Batch collect repayments by group',
              color: AppTheme.accentAmber,
              onTap: () {
                context.push('${AppRouter.collectionRoute}?centerCode=C001&centerName=${Uri.encodeComponent("Taunggyi Central Center")}');
              },
            ),
            _ActionTile(
              icon: Icons.savings_outlined,
              title: 'Village Savings Accounts',
              subtitle: 'Collect savings deposits & open passbook at meeting',
              color: AppTheme.accentTeal,
              onTap: () {
                context.push(AppRouter.savingsRoute);
              },
            ),
            _ActionTile(
              icon: Icons.health_and_safety_outlined,
              title: 'Mutual Insurance Claim',
              subtitle: 'Emergency hospitalization & disaster claim intake',
              color: AppTheme.accentCrimson,
              onTap: () {
                context.push(AppRouter.claimRoute);
              },
            ),
            _ActionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Cash Management & Vault',
              subtitle: 'Monitor cash in hand & branch QR handover',
              color: AppTheme.primaryNavy,
              onTap: () {
                context.push(AppRouter.cashRoute);
              },
            ),
            _ActionTile(
              icon: Icons.print_outlined,
              title: l10n.bluetoothPrinterTitle,
              subtitle: 'Pair & test 58mm/80mm receipt printing',
              color: AppTheme.textPrimary,
              onTap: () {
                context.push(AppRouter.printerRoute);
              },
            ),
            _ActionTile(
              icon: Icons.cloud_sync_outlined,
              title: l10n.offlineSyncTitle,
              subtitle: 'Download schedules & upload offline sync queue',
              color: AppTheme.accentTeal,
              onTap: () {
                context.push(AppRouter.syncRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
