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
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';
import 'package:bmf_customer/features/payments/domain/models/customer_transaction.dart';
import 'package:bmf_customer/features/payments/domain/repositories/payment_repository.dart';
import 'package:bmf_customer/features/savings/domain/repositories/savings_repository.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import 'package:bmf_customer/features/home/presentation/widgets/quick_actions_row.dart';

/// Redesigned Streamlined Customer Home Screen.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onOpenDrawer,
    this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CustomerTransaction> _recentTransactions = [];
  List<String> _activeShortcuts = ['APPLY_LOAN', 'SAVINGS', 'INSURANCE', 'BRANCHES'];
  double _totalSavingBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedQuickActions();
    _refreshData();
  }

  Future<void> _loadSavedQuickActions() async {
    final saved = await SecureStorageService().getQuickActions();
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _activeShortcuts = saved;
      });
    }
  }

  void _refreshData() {
    final authState = context.read<CustomerAuthBloc>().state;
    final nrc = authState is AuthAuthenticated ? authState.profile.nrcFormatted : '';
    final customerCode = authState is AuthAuthenticated ? authState.profile.customerCode : '';
    final lookupId = customerCode.isNotEmpty ? customerCode : nrc;

    if (lookupId.isNotEmpty) {
      context.read<CustomerLoanBloc>().add(LoadActiveLoansRequested(lookupId));
      _fetchTransactions(lookupId);
      _fetchSavings(lookupId);
    }
  }

  Future<void> _fetchSavings(String identifier) async {
    try {
      final accounts = await context.read<SavingsRepository>().getSavingAccounts(identifier);
      if (mounted && accounts.isNotEmpty) {
        final total = accounts.fold(0.0, (sum, a) => sum + a.balanceMmk);
        setState(() {
          _totalSavingBalance = total;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTransactions(String customerCode) async {
    try {
      final txs = await context.read<PaymentRepository>().getCustomerTransactions(customerCode);
      if (mounted) {
        setState(() {
          _recentTransactions = txs;
        });
      }
    } catch (_) {}
  }

  void _showCustomizeQuickActionsModal(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final allAvailable = [
      {'key': 'APPLY_LOAN', 'label': l10n.menuApplyLoanTitle, 'icon': Icons.app_registration_rounded, 'color': CustomerTheme.primaryCyan},
      {'key': 'SAVINGS', 'label': l10n.menuSavingsTitle, 'icon': Icons.savings_outlined, 'color': CustomerTheme.statusCurrent},
      {'key': 'INSURANCE', 'label': l10n.menuInsuranceTitle, 'icon': Icons.health_and_safety_outlined, 'color': CustomerTheme.accentCrimson},
      {'key': 'BRANCHES', 'label': l10n.menuBranchesTitle, 'icon': Icons.location_on_outlined, 'color': const Color(0xFF6366F1)},
      {'key': 'SCAN_QR', 'label': l10n.navScanQr, 'icon': Icons.qr_code_scanner_rounded, 'color': const Color(0xFF0D9488)},
      {'key': 'LOANS', 'label': l10n.menuLoansTitle, 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFFF59E0B)},
      {'key': 'HISTORY', 'label': l10n.navHistory, 'icon': Icons.receipt_long_outlined, 'color': const Color(0xFF8B5CF6)},
    ];

    List<String> tempSelected = List.from(_activeShortcuts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CustomerTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: CustomerTheme.primaryNavy.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.tune_rounded, size: 16, color: CustomerTheme.primaryNavy),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.customizeQuickActions,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: CustomerTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CustomerTheme.primaryCyan.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tempSelected.length}/4',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CustomerTheme.primaryCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.customizeQuickActionsDesc,
                      style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allAvailable.map((item) {
                        final key = item['key'] as String;
                        final label = item['label'] as String;
                        final icon = item['icon'] as IconData;
                        final color = item['color'] as Color;
                        final isSelected = tempSelected.contains(key);

                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                if (tempSelected.length <= 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.minShortcutsRequired),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                tempSelected.remove(key);
                              } else {
                                if (tempSelected.length >= 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.maxShortcutsReached),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                tempSelected.add(key);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withAlpha(20) : CustomerTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color : CustomerTheme.borderSubtle,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 16, color: isSelected ? color : CustomerTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? CustomerTheme.textPrimary : CustomerTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                  size: 15,
                                  color: isSelected ? color : CustomerTheme.textSecondary.withAlpha(120),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(modalCtx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CustomerTheme.textSecondary,
                              side: const BorderSide(color: CustomerTheme.borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(l10n.cancel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await SecureStorageService().saveQuickActions(tempSelected);
                              if (mounted) {
                                setState(() {
                                  _activeShortcuts = tempSelected;
                                });
                              }
                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomerTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(l10n.saveChanges, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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
                  _refreshData();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showMemberQrModal(BuildContext context, MemberProfile member) {
    final l10n = CustomerLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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
              Text(
                'NRC: ${member.nrcFormatted}',
                style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                member.centerName,
                style: const TextStyle(fontSize: 11, color: CustomerTheme.primaryNavy, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 10,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded, size: 24),
                tooltip: l10n.home,
                onPressed: widget.onOpenDrawer,
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, color: CustomerTheme.secondaryAmber, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l10n.appTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
            tooltip: l10n.notificationsTitle,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            onPressed: () => context.push(AppRouter.notificationsRoute),
          ),
          const SizedBox(width: 4),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return InkWell(
                onTap: () => _showLanguageDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        langState.currentLanguage.code.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            _refreshData();
          }
        },
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
            child: RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: CustomerTheme.primaryNavy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Member Profile Banner
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: CustomerTheme.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withAlpha(35),
                            child: const Icon(Icons.person, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${member.fullName} (${member.customerCode})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${member.nrcFormatted} • ${member.centerName}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _showMemberQrModal(context, member),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: CustomerTheme.secondaryAmber.withAlpha(35),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: CustomerTheme.secondaryAmber.withAlpha(120)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.qr_code_2, color: CustomerTheme.secondaryAmber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.digitalMemberCard,
                                    style: const TextStyle(
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
                    ),

                    const SizedBox(height: 12),

                    // 2. Financial Overview Hero Summary Card
                    BlocBuilder<CustomerLoanBloc, CustomerLoanState>(
                      builder: (context, loanState) {
                        double totalOutstandingDebt = 0.0;
                        double nextDueAmount = 0.0;
                        if (loanState is LoanListLoaded && loanState.loans.isNotEmpty) {
                          totalOutstandingDebt = loanState.loans.fold(
                            0.0,
                            (sum, l) => sum + l.remainingPrincipalMmk,
                          );
                          if (loanState.loans.first.nextDueAmountMmk > 0) {
                            nextDueAmount = loanState.loans.first.nextDueAmountMmk;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(color: CustomerTheme.borderSubtle),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: CustomerTheme.primaryNavy.withAlpha(15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.account_balance_wallet_outlined,
                                                color: CustomerTheme.primaryNavy,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                l10n.outstandingLoanMetric,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: CustomerTheme.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: CustomerTheme.statusCurrent.withAlpha(20),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: CustomerTheme.statusCurrent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              l10n.memberActiveStatus,
                                              style: const TextStyle(
                                                color: CustomerTheme.statusCurrent,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    CurrencyFormatter.formatMmk(totalOutstandingDebt),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: CustomerTheme.primaryNavy,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: CustomerTheme.borderSubtle),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CustomerMetricChip(
                                          label: l10n.dueMetric,
                                          value: CurrencyFormatter.formatMmk(nextDueAmount),
                                          color: CustomerTheme.secondaryAmber,
                                          icon: Icons.calendar_today_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _CustomerMetricChip(
                                          label: l10n.totalSavingsMetric,
                                          value: CurrencyFormatter.formatMmk(_totalSavingBalance > 0 ? _totalSavingBalance : member.totalSavingBalanceMmk),
                                          color: CustomerTheme.statusCurrent,
                                          icon: Icons.savings_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _CustomerMetricChip(
                                          label: l10n.loyaltyPointsMetric,
                                          value: '${member.loyaltyPoints}',
                                          color: CustomerTheme.primaryNavy,
                                          icon: Icons.military_tech_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 3. 1-Row Quick Actions Shortcut Bar
                    QuickActionsRow(
                      activeShortcuts: _activeShortcuts,
                      onApplyLoan: () => context.push(AppRouter.fastLoanRoute),
                      onSavings: () => context.push(AppRouter.savingsRoute, extra: member.customerCode.isNotEmpty ? member.customerCode : member.nrcFormatted),
                      onInsurance: () => context.push(AppRouter.insuranceClaimRoute, extra: member.customerCode.isNotEmpty ? member.customerCode : member.nrcFormatted),
                      onBranches: () => context.push(AppRouter.branchNetworkRoute),
                      onScanQr: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(2);
                        } else {
                          context.push(AppRouter.paymentQrRoute);
                        }
                      },
                      onLoans: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        } else {
                          context.push(AppRouter.loansRoute);
                        }
                      },
                      onHistory: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(3);
                        } else {
                          context.push(AppRouter.transactionHistoryRoute);
                        }
                      },
                      onCustomize: () => _showCustomizeQuickActionsModal(context),
                    ),

                    const SizedBox(height: 12),

                    // 4. Recent Activity Summary Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: CustomerTheme.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: CustomerTheme.accentTeal.withAlpha(15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_outlined,
                                          size: 14,
                                          color: CustomerTheme.accentTeal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.navHistory,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: CustomerTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (widget.onNavigateTab != null) {
                                        widget.onNavigateTab!(3);
                                      } else {
                                        context.push(AppRouter.transactionHistoryRoute);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            l10n.viewAll,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: CustomerTheme.primaryCyan,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.arrow_forward_ios, size: 10, color: CustomerTheme.primaryCyan),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_recentTransactions.isEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  alignment: Alignment.center,
                                  child: Text(
                                    l10n.noRecentTransactions,
                                    style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary),
                                  ),
                                )
                              else
                                ..._recentTransactions.take(3).map((tx) => _buildTransactionRow(context, tx, l10n)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 5. Assigned Officer & Center Info Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: CustomerTheme.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: CustomerTheme.primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.branchNetwork,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: CustomerTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildCenterInfoRow(l10n.centerLabel, member.centerName),
                              _buildCenterInfoRow(l10n.groupLabel, member.groupName),
                              _buildCenterInfoRow(l10n.meetingScheduleLabel, l10n.weeklyMeetingTime),
                              _buildCenterInfoRow(l10n.assignedOfficerLabel, 'U Aung Kyaw (09450011223)'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, CustomerTransaction tx, CustomerLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: CustomerTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CustomerTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CustomerTheme.statusCurrent.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_outline, color: CustomerTheme.statusCurrent, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tx.transactionId} • ${tx.contractCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: CustomerTheme.primaryNavy),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.periodNumberLabel} #${tx.periodNumber} • ${tx.transactionTime.day}/${tx.transactionTime.month}/${tx.transactionTime.year}',
                    style: const TextStyle(fontSize: 10, color: CustomerTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '+${CurrencyFormatter.formatMmk(tx.totalAmountMmk)}',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: CustomerTheme.statusCurrent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
            ),
          ),
          const Text(' :  ', style: TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CustomerTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerMetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _CustomerMetricChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: CustomerTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
