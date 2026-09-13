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

/// Comprehensive Account & Settings Screen for Field Officers.
class OfficerAccountScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const OfficerAccountScreen({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<OfficerAccountScreen> createState() => _OfficerAccountScreenState();
}

class _OfficerAccountScreenState extends State<OfficerAccountScreen> {
  bool _biometricEnabled = true;

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
    final branchDisplay = (authState is AuthAuthenticated && authState.profile.branchName != null && authState.profile.branchName!.isNotEmpty)
        ? authState.profile.branchName!
        : l10n.agentBranchLocation;
    final officerSub = officerCode.isNotEmpty
        ? '$officerCode • $branchDisplay • ${l10n.networkOnline}'
        : '$branchDisplay • ${l10n.networkOnline}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 10,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded, size: 24),
                tooltip: 'Menu',
                onPressed: widget.onOpenDrawer,
              )
            : null,
        title: Text(
          l10n.accountSettings,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
            tooltip: l10n.signOut,
            onPressed: () => _confirmSignOut(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Officer Profile Header Banner
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            officerSub,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Hardware & Printer Settings Section
              _buildSectionCard(
                title: l10n.hardwarePrinterSection,
                icon: Icons.print_outlined,
                color: AppTheme.primaryNavy,
                children: [
                  _buildListTile(
                    icon: Icons.bluetooth_connected_rounded,
                    title: l10n.bluetoothPrinterTitle,
                    subtitle: l10n.thermalPrinterDesc,
                    trailingBadge: l10n.connectedBadge,
                    badgeColor: AppTheme.accentEmerald,
                    onTap: () => context.push(AppRouter.printerRoute),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 3. Offline Data & Synchronization Section
              _buildSectionCard(
                title: l10n.offlineDataSection,
                icon: Icons.cloud_sync_outlined,
                color: AppTheme.accentTeal,
                children: [
                  _buildListTile(
                    icon: Icons.sync_rounded,
                    title: l10n.offlineSyncTitle,
                    subtitle: l10n.offlineSyncDesc,
                    trailingBadge: '0 ${l10n.pendingUploadsBadge}',
                    badgeColor: AppTheme.accentEmerald,
                    onTap: () => context.push(AppRouter.syncRoute),
                  ),
                  _buildListTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.manageAgentCashTitle,
                    subtitle: l10n.manageAgentCashDesc,
                    onTap: () => context.push(AppRouter.cashRoute),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 4. Security & Biometrics Section
              _buildSectionCard(
                title: l10n.securitySection,
                icon: Icons.security_outlined,
                color: AppTheme.primarySlate,
                children: [
                  SwitchListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    secondary: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: AppTheme.accentEmerald, size: 18),
                    ),
                    title: Text(
                      l10n.biometricFingerprint,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      l10n.biometricFingerprintDesc,
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                    ),
                    value: _biometricEnabled,
                    activeThumbColor: AppTheme.accentEmerald,
                    onChanged: (val) {
                      setState(() {
                        _biometricEnabled = val;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 12, endIndent: 12, color: AppTheme.borderSubtle),
                  _buildListTile(
                    icon: Icons.shield_outlined,
                    title: l10n.deviceSecurity,
                    subtitle: l10n.sqliteEncryptionDesc,
                    trailingBadge: l10n.secureBadge,
                    badgeColor: AppTheme.accentEmerald,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 5. System Utilities & Support
              _buildSectionCard(
                title: l10n.systemSupportSection,
                icon: Icons.help_outline_rounded,
                color: AppTheme.accentOrange,
                children: [
                  BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, langState) {
                      return _buildListTile(
                        icon: Icons.language_rounded,
                        title: l10n.languageDisplay,
                        subtitle: '${langState.currentLanguage.displayName} (${langState.currentLanguage.nativeName})',
                        trailingBadge: langState.currentLanguage.code.toUpperCase(),
                        badgeColor: AppTheme.primaryNavy,
                        onTap: () => _showLanguageDialog(context),
                      );
                    },
                  ),
                  _buildListTile(
                    icon: Icons.headset_mic_outlined,
                    title: l10n.itHotline,
                    subtitle: l10n.itHotlineDesc,
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.appVersion,
                    subtitle: l10n.appVersionSubtitle,
                    trailingBadge: l10n.latestVersionBadge,
                    badgeColor: AppTheme.accentEmerald,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 6. Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(l10n.signOut, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  onPressed: () => _confirmSignOut(context),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.borderSubtle),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingBadge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryNavy, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppTheme.primaryNavy).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailingBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor ?? AppTheme.primaryNavy,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }
}
