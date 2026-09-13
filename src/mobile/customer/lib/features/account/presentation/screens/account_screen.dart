import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/bloc/language/language_cubit.dart';
import 'package:bmf_customer/core/bloc/language/language_state.dart';
import 'package:bmf_customer/core/enums/app_language.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/features/auth/domain/models/member_profile.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';

/// Comprehensive Account, Profile, Security & Settings Screen.
class AccountScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const AccountScreen({super.key, this.onOpenDrawer});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometricEnabled = true;
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onOpenDrawer,
              )
            : null,
        title: Text(
          l10n.navAccount,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
        builder: (context, authState) {
          final member = authState is AuthAuthenticated
              ? authState.profile
              : const MemberProfile(
                  memberId: '',
                  customerCode: '',
                  nrcFormatted: '',
                  fullName: 'BMF Member',
                  phone: '',
                  centerName: '',
                  groupName: '',
                  totalSavingBalanceMmk: 0.0,
                  loyaltyPoints: 0,
                  hasActiveLoans: false,
                  isPinConfigured: false,
                );

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Member Profile Card
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: CustomerTheme.borderSubtle),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: CustomerTheme.primaryNavy.withAlpha(20),
                            child: const Icon(Icons.person, color: CustomerTheme.primaryNavy, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.fullName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: CustomerTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${member.customerCode} • ${member.nrcFormatted}',
                                  style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${member.centerName} (${member.groupName})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: CustomerTheme.primaryCyan,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.qr_code_2, color: CustomerTheme.secondaryAmber, size: 28),
                            tooltip: l10n.digitalMemberCard,
                            onPressed: () => _showMemberQrModal(context, member),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Security & Authentication Section
                  _buildSectionHeader(l10n.securityTitle),
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: CustomerTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.lock_outline_rounded,
                          title: l10n.changePin,
                          subtitle: l10n.enter6DigitPin,
                          color: CustomerTheme.primaryNavy,
                          onTap: () => _showChangePinModal(context),
                        ),
                        const Divider(height: 1, indent: 52),
                        SwitchListTile(
                          secondary: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: CustomerTheme.statusCurrent.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fingerprint_rounded, color: CustomerTheme.statusCurrent, size: 20),
                          ),
                          title: Text(
                            l10n.biometricAuth,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(l10n.biometricSubtitle, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                          value: _biometricEnabled,
                          activeTrackColor: CustomerTheme.statusCurrent,
                          onChanged: (val) {
                            setState(() => _biometricEnabled = val);
                          },
                        ),
                        const Divider(height: 1, indent: 52),
                        _buildSettingTile(
                          icon: Icons.shield_outlined,
                          title: l10n.deviceSecurity,
                          subtitle: l10n.deviceSecurityDesc,
                          color: CustomerTheme.secondaryAmber,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CustomerTheme.statusCurrent.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(l10n.deviceSecurityPass, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CustomerTheme.statusCurrent)),
                          ),
                          onTap: () => _showDeviceSecurityModal(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Settings & Preferences Section
                  _buildSectionHeader(l10n.settingsAndPreferences),
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: CustomerTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        BlocBuilder<LanguageCubit, LanguageState>(
                          builder: (context, langState) {
                            return _buildSettingTile(
                              icon: Icons.language_rounded,
                              title: l10n.languageSettingTitle,
                              subtitle: '${langState.currentLanguage.displayName} (${langState.currentLanguage.nativeName})',
                              color: CustomerTheme.primaryCyan,
                              onTap: () => _showLanguageDialog(context),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 52),
                        SwitchListTile(
                          secondary: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF3B82F6), size: 20),
                          ),
                          title: Text(
                            l10n.dueReminderNotifications,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(l10n.dueReminderDesc, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                          value: _pushNotificationsEnabled,
                          activeTrackColor: CustomerTheme.primaryCyan,
                          onChanged: (val) {
                            setState(() => _pushNotificationsEnabled = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Utilities & Support Section
                  _buildSectionHeader(l10n.utilitiesTitle),
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: CustomerTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.account_balance_outlined,
                          title: l10n.branchNetwork,
                          subtitle: l10n.menuBranchesSubtitle,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => context.push(AppRouter.branchNetworkRoute),
                        ),
                        const Divider(height: 1, indent: 52),
                        _buildSettingTile(
                          icon: Icons.headset_mic_outlined,
                          title: l10n.supportHotline,
                          subtitle: '1800-BMF (09450011223)',
                          color: const Color(0xFF10B981),
                          onTap: () => _showSupportHotlineModal(context),
                        ),
                        const Divider(height: 1, indent: 52),
                        _buildSettingTile(
                          icon: Icons.policy_outlined,
                          title: l10n.termsAndPrivacy,
                          subtitle: 'CBM & FRD Compliance',
                          color: CustomerTheme.primaryNavy,
                          onTap: () => _showTermsModal(context),
                        ),
                        const Divider(height: 1, indent: 52),
                        _buildSettingTile(
                          icon: Icons.info_outline_rounded,
                          title: l10n.appVersion,
                          subtitle: 'v2.6.0 (Build 2026.09)',
                          color: CustomerTheme.textSecondary,
                          trailing: const Text('2026', style: TextStyle(fontSize: 12, color: CustomerTheme.textSecondary)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showSignOutDialog(context),
                      icon: const Icon(Icons.logout_rounded, color: CustomerTheme.accentCrimson, size: 18),
                      label: Text(
                        l10n.signOut,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomerTheme.accentCrimson,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: CustomerTheme.accentCrimson.withAlpha(80)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: CustomerTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CustomerTheme.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 18, color: CustomerTheme.textSecondary) : null),
    );
  }

  void _showMemberQrModal(BuildContext context, MemberProfile member) {
    final l10n = CustomerLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.memberQrTitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: CustomerTheme.primaryNavy, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 130, color: CustomerTheme.primaryNavy),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${member.fullName} (${member.customerCode})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
            ),
            const SizedBox(height: 2),
            Text('NRC: ${member.nrcFormatted}', style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(member.centerName, style: const TextStyle(fontSize: 11, color: CustomerTheme.primaryNavy, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.close),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePinModal(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.changePinSecurityTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.currentPinLabel,
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.newPinLabel,
                prefixIcon: const Icon(Icons.lock_reset, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.confirmNewPinLabel,
                prefixIcon: const Icon(Icons.check_circle_outline, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pinChangedSuccess)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryCyan, foregroundColor: Colors.white),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeviceSecurityModal(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: CustomerTheme.statusCurrent, size: 24),
                const SizedBox(width: 8),
                Text(l10n.deviceSecurityStatus, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy)),
              ],
            ),
            const SizedBox(height: 14),
            _buildSecurityCheckItem('SSL / TLS 1.3 Certificate Pinning', true),
            _buildSecurityCheckItem('Root / Jailbreak Detection (Tamper-Proof)', true),
            _buildSecurityCheckItem('Flutter Secure Encrypted Storage (AES-256)', true),
            _buildSecurityCheckItem('Screen Protection & Anti-Overlay Shield', true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy, foregroundColor: Colors.white),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCheckItem(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(passed ? Icons.check_circle : Icons.error, color: passed ? CustomerTheme.statusCurrent : CustomerTheme.accentCrimson, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: CustomerTheme.textPrimary))),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.selectLanguage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = lang == currentLang;
            return ListTile(
              title: Text(
                '${lang.displayName} (${lang.nativeName})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? CustomerTheme.primaryCyan : CustomerTheme.textPrimary,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: CustomerTheme.primaryCyan) : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(lang);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSupportHotlineModal(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.supportHotline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.headset_mic_rounded, color: CustomerTheme.primaryNavy, size: 48),
            const SizedBox(height: 12),
            const Text('1800-BMF (09450011223)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy)),
            const SizedBox(height: 6),
            Text(l10n.medicalBenefitDesc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy, foregroundColor: Colors.white),
              child: Text(l10n.close),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsModal(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.termsAndPrivacy, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy)),
            const SizedBox(height: 12),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'BMF Microfinance Myanmar strictly adheres to Central Bank of Myanmar (CBM) MMQR guidelines, Financial Regulatory Department (FRD) Directive No. 4/2021, ISO/IEC 27001, and Zero Trust security standards.\n\n'
                  '1. Solidarity Credit Group Lending Policy.\n'
                  '2. Non-Interest Yield and Accrued Profit Sharing Policy.\n'
                  '3. Mutual Aid Fund Disbursement Criteria.\n'
                  '4. Personal Data & NRC Protection under Myanmar Financial Security Regulations.',
                  style: TextStyle(fontSize: 12.5, height: 1.5, color: CustomerTheme.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy, foregroundColor: Colors.white),
                child: Text(l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CustomerAuthBloc>().add(const LogoutRequested());
              context.go(AppRouter.loginIdentifierRoute);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.accentCrimson, foregroundColor: Colors.white),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}
