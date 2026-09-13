import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/bloc/language/language_cubit.dart';
import 'package:bmf_customer/core/enums/app_language.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/features/auth/domain/models/member_profile.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';

/// Full-featured Navigation Sidebar (Drawer) for BMF Member Application.
class MemberDrawer extends StatelessWidget {
  final MemberProfile? member;
  final Function(int tabIndex)? onSelectTab;
  final VoidCallback? onShowQr;
  final VoidCallback? onShowLoanApply;
  final VoidCallback? onShowBranches;

  const MemberDrawer({
    super.key,
    this.member,
    this.onSelectTab,
    this.onShowQr,
    this.onShowLoanApply,
    this.onShowBranches,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final authState = context.watch<CustomerAuthBloc>().state;
    final activeMember = member ??
        (authState is AuthAuthenticated
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
              ));

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Member Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
              decoration: const BoxDecoration(
                gradient: CustomerTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withAlpha(40),
                        child: const Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (onShowQr != null) onShowQr!();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: CustomerTheme.secondaryAmber.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: CustomerTheme.secondaryAmber.withAlpha(120)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_2, color: CustomerTheme.secondaryAmber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'QR ID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeMember.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activeMember.customerCode} • ${activeMember.nrcFormatted}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activeMember.centerName,
                      style: const TextStyle(color: CustomerTheme.secondaryAmber, fontSize: 10.5, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader(l10n.quickServices),
                  _buildDrawerTile(
                    icon: Icons.home_outlined,
                    title: l10n.navHome,
                    color: CustomerTheme.primaryNavy,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(0);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.calendar_month_outlined,
                    title: l10n.menuLoansTitle,
                    color: CustomerTheme.primaryNavy,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) {
                        onSelectTab!(1);
                      } else {
                        context.push(AppRouter.loansRoute, extra: activeMember.nrcFormatted);
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: l10n.menuMmqrTitle,
                    color: CustomerTheme.secondaryAmber,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) {
                        onSelectTab!(2);
                      } else {
                        context.push(AppRouter.paymentQrRoute, extra: {'contractCode': '', 'amountMmk': 0.0});
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.savings_outlined,
                    title: l10n.menuSavingsTitle,
                    color: CustomerTheme.statusCurrent,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRouter.savingsRoute, extra: activeMember.nrcFormatted);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.health_and_safety_outlined,
                    title: l10n.menuInsuranceTitle,
                    color: CustomerTheme.accentCrimson,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRouter.insuranceClaimRoute, extra: activeMember.nrcFormatted);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.app_registration_rounded,
                    title: l10n.menuApplyLoanTitle,
                    color: CustomerTheme.primaryCyan,
                    onTap: () {
                      Navigator.pop(context);
                      if (onShowLoanApply != null) {
                        onShowLoanApply!();
                      } else {
                        context.push(AppRouter.fastLoanRoute);
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.navHistory,
                    color: CustomerTheme.accentTeal,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) {
                        onSelectTab!(3);
                      } else {
                        context.push(AppRouter.transactionHistoryRoute);
                      }
                    },
                  ),

                  const Divider(height: 20),
                  _buildSectionHeader(l10n.utilitiesTitle),
                  _buildDrawerTile(
                    icon: Icons.location_on_outlined,
                    title: l10n.branchNetwork,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Navigator.pop(context);
                      if (onShowBranches != null) {
                        onShowBranches!();
                      } else {
                        context.push(AppRouter.branchNetworkRoute);
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.notifications_none_rounded,
                    title: l10n.notificationsTitle,
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRouter.notificationsRoute);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.person_outline_rounded,
                    title: l10n.navAccount,
                    color: CustomerTheme.primaryNavy,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(4);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.language,
                    title: l10n.languageSettingTitle,
                    color: CustomerTheme.textSecondary,
                    onTap: () {
                      Navigator.pop(context);
                      _showLanguageDialog(context, l10n);
                    },
                  ),
                ],
              ),
            ),

            // 3. Footer: Version & Logout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: CustomerTheme.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BMF Member App',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                      ),
                      Text(
                        'v1.0.0',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmLogout(context, l10n);
                    },
                    icon: const Icon(Icons.logout, size: 16, color: CustomerTheme.accentCrimson),
                    label: Text(
                      l10n.signOut,
                      style: const TextStyle(color: CustomerTheme.accentCrimson, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 32,
        height: 32,
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
          color: CustomerTheme.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: CustomerTheme.textSecondary),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context, CustomerLocalizations l10n) {
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.selectLanguage),
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
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, CustomerLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.signOut),
          content: Text(l10n.signOutConfirmDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<CustomerAuthBloc>().add(const LogoutRequested());
                context.go(AppRouter.loginIdentifierRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerTheme.accentCrimson,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
  }
}
