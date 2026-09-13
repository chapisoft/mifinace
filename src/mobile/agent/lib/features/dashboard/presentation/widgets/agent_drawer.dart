import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../core/bloc/language/language_state.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Modern sliding navigation drawer for BMF Field Officer App.
class AgentDrawer extends StatelessWidget {
  const AgentDrawer({super.key});

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.language, color: AppTheme.primaryNavy, size: 20),
            const SizedBox(width: 8),
            Text(l10n.selectLanguageTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = lang == currentLang;
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              selected: isSelected,
              selectedTileColor: AppTheme.accentEmerald.withAlpha(25),
              title: Text(
                '${lang.displayName} (${lang.nativeName})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.accentEmerald : AppTheme.textPrimary,
                  fontSize: 13.5,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.accentEmerald, size: 20) : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(lang);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 22),
            const SizedBox(width: 8),
            Text(l10n.signOut, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          l10n.confirmSignOut,
          style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancelButton, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Close Drawer
              context.go(AppRouter.loginRoute);
            },
            child: Text(l10n.signOut, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final officerName = (authState is AuthAuthenticated && authState.profile.fullName.isNotEmpty)
        ? authState.profile.fullName
        : (authState is AuthAuthenticated && authState.profile.username.isNotEmpty ? authState.profile.username : l10n.agentAuthorizedRole);
    final officerCode = (authState is AuthAuthenticated && authState.profile.username.isNotEmpty)
        ? authState.profile.username
        : '';
    final officerSub = officerCode.isNotEmpty
        ? '$officerCode • ${l10n.agentAuthorizedRole}'
        : l10n.agentAuthorizedRole;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. Officer Profile Header Banner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withAlpha(30),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            officerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            officerSub,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentEmerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${l10n.agentBranchLocation} • ${l10n.networkOnline}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Navigation Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _buildSectionHeader(l10n.agentOperationsSection),
                _buildDrawerItem(
                  icon: Icons.assignment_outlined,
                  title: l10n.collectionSheetTitle,
                  color: AppTheme.accentEmerald,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('${AppRouter.collectionRoute}?centerCode=C001&centerName=${Uri.encodeComponent("Taunggyi Central Center")}');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.app_registration_rounded,
                  title: l10n.newLoanApplication,
                  color: AppTheme.primaryNavy,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.loanApplyRoute);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.groups_outlined,
                  title: l10n.centersTitle,
                  color: AppTheme.primarySlate,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.centersRoute);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.savings_outlined,
                  title: l10n.navSavingsTitle,
                  color: AppTheme.accentTeal,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.savingsRoute);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.navCashTitle,
                  color: AppTheme.accentOrange,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.cashRoute);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.health_and_safety_outlined,
                  title: l10n.navInsuranceTitle,
                  color: AppTheme.accentCrimson,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.claimRoute);
                  },
                ),

                const Divider(height: 16, color: AppTheme.borderSubtle),

                _buildSectionHeader(l10n.devicesSyncSection),
                _buildDrawerItem(
                  icon: Icons.print_outlined,
                  title: l10n.bluetoothPrinterTitle,
                  color: AppTheme.textPrimary,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.printerRoute);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.cloud_sync_outlined,
                  title: l10n.offlineSyncTitle,
                  color: AppTheme.accentTeal,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(AppRouter.syncRoute);
                  },
                ),

                const Divider(height: 16, color: AppTheme.borderSubtle),

                _buildSectionHeader(l10n.systemSettingsSection),
                BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, langState) {
                    return _buildDrawerItem(
                      icon: Icons.language_rounded,
                      title: '${l10n.languageDisplay} (${langState.currentLanguage.code.toUpperCase()})',
                      color: AppTheme.primaryNavy,
                      onTap: () => _showLanguageDialog(context),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: l10n.signOut,
                  color: AppTheme.errorRed,
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),

          // 3. App Version Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(l10n.appTitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                const Text('v2.6.0 (Build 2026)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
