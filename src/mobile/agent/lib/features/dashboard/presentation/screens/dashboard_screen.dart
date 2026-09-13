import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../core/bloc/language/language_state.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../cash/domain/models/cash_summary.dart';
import '../../../cash/presentation/widgets/qr_handover_dialog.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../widgets/agent_quick_actions_row.dart';

/// Redesigned Streamlined Field Operations Dashboard for Credit Officers.
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final Function(int tabIndex)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onOpenDrawer,
    this.onNavigateTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> _activeShortcuts = ['COLLECTION', 'NEW_LOAN', 'SAVINGS', 'CENTERS'];

  @override
  void initState() {
    super.initState();
    _loadSavedShortcuts();
  }

  Future<void> _loadSavedShortcuts() async {
    final saved = await SecureStorageService().getQuickActions();
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _activeShortcuts = saved;
      });
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    final l10n = AppLocalizations.of(context);
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

  void _showHandoverModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.read<AuthBloc>().state;
    final officerId = authState is AuthAuthenticated ? authState.profile.username : '';
    final branchCode = authState is AuthAuthenticated ? (authState.profile.branchCode ?? 'BR001') : 'BR001';
    final summary = CashSummary(
      officerId: officerId,
      currentCashBalanceMmk: 0,
      totalRepaymentMmk: 0,
      totalSavingMmk: 0,
      safeLimitMmk: 2000000,
      isExceedingLimit: false,
      transactionCount: 0,
      entries: const [],
    );
    final qrPayload = 'BMF_HANDOVER:$branchCode:$officerId:${summary.currentCashBalanceMmk.toInt()}:${DateTime.now().millisecondsSinceEpoch}';
    showDialog(
      context: context,
      builder: (ctx) => QrHandoverDialog(
        summary: summary,
        qrPayload: qrPayload,
        onHandoverConfirmed: () {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cashHandoverSuccess)),
          );
        },
      ),
    );
  }

  void _showCustomizeShortcutsModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allAvailable = [
      {'key': 'COLLECTION', 'label': l10n.actionCollectRepayment, 'icon': Icons.assignment_turned_in_outlined, 'color': AppTheme.accentEmerald},
      {'key': 'NEW_LOAN', 'label': l10n.actionNewLoan, 'icon': Icons.app_registration_rounded, 'color': AppTheme.primaryNavy},
      {'key': 'SAVINGS', 'label': l10n.actionSavings, 'icon': Icons.savings_outlined, 'color': AppTheme.accentTeal},
      {'key': 'CENTERS', 'label': l10n.actionCenters, 'icon': Icons.groups_outlined, 'color': AppTheme.accentOrange},
      {'key': 'CASH', 'label': l10n.actionManageCash, 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFF6366F1)},
      {'key': 'INSURANCE', 'label': l10n.actionInsurance, 'icon': Icons.health_and_safety_outlined, 'color': AppTheme.accentCrimson},
      {'key': 'PRINTER', 'label': l10n.actionPrinter, 'icon': Icons.print_outlined, 'color': const Color(0xFF0D9488)},
      {'key': 'SYNC', 'label': l10n.actionSync, 'icon': Icons.sync_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    final tempSelected = List<String>.from(_activeShortcuts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
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
                      color: AppTheme.borderSubtle,
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
                            color: AppTheme.primaryNavy.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune_rounded, color: AppTheme.primaryNavy, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.customizeAgentShortcuts,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tempSelected.length}/4',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentEmerald,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.customizeAgentShortcutsDesc,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
                              return;
                            }
                            tempSelected.remove(key);
                          } else {
                            if (tempSelected.length >= 4) {
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
                          color: isSelected ? color.withAlpha(20) : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppTheme.borderSubtle,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 16, color: isSelected ? color : AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              size: 15,
                              color: isSelected ? color : AppTheme.textSecondary.withAlpha(120),
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
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.borderSubtle),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(l10n.cancelButton, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
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
                        child: Text(l10n.saveCustomization, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    final officerSub = officerCode.isNotEmpty ? '$officerCode • $branchDisplay' : branchDisplay;

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'BMF Microfinance',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.2),
                  ),
                  Text(
                    l10n.loginSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 22),
            tooltip: l10n.offlineSyncTitle,
            onPressed: () => context.push(AppRouter.syncRoute),
          ),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return InkWell(
                onTap: () => _showLanguageDialog(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Officer Profile & Status Header Banner (Spacious & Clean)
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
                            officerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            officerSub,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentEmerald.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentEmerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.networkOnline,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Target & Collection Summary Hero Card (Spacious & Prominent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy.withAlpha(15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.track_changes_rounded,
                                    color: AppTheme.primaryNavy,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.todayTarget,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentEmerald.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '68% ${l10n.progressCompleted}',
                                style: const TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              CurrencyFormatter.formatMmk(850000),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '/ ${CurrencyFormatter.formatMmk(1250000)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.68,
                            minHeight: 6,
                            backgroundColor: AppTheme.borderSubtle,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppTheme.borderSubtle),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricChip(
                                label: l10n.collectedAmount,
                                value: CurrencyFormatter.formatMmk(850000),
                                color: AppTheme.accentEmerald,
                                icon: Icons.check_circle_outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricChip(
                                label: l10n.remainingAmount,
                                value: CurrencyFormatter.formatMmk(400000),
                                color: AppTheme.accentOrange,
                                icon: Icons.pending_outlined,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricChip(
                                label: l10n.syncPending,
                                value: '0 ${l10n.itemsCount}',
                                color: AppTheme.textSecondary,
                                icon: Icons.cloud_done_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. 1-Row Quick Actions Shortcut Bar (Thường sử dụng & Cho phép tùy biến)
              AgentQuickActionsRow(
                activeShortcuts: _activeShortcuts,
                onCollection: () {
                  context.push('${AppRouter.collectionRoute}?centerCode=C001&centerName=${Uri.encodeComponent("Taunggyi Central Center")}');
                },
                onNewLoan: () => context.push(AppRouter.loanApplyRoute),
                onSavings: () => context.push(AppRouter.savingsRoute),
                onCenters: () {
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(1);
                  } else {
                    context.push(AppRouter.centersRoute);
                  }
                },
                onCash: () => _showHandoverModal(context),
                onInsurance: () => context.push(AppRouter.claimRoute),
                onPrinter: () => context.push(AppRouter.printerRoute),
                onSync: () => context.push(AppRouter.syncRoute),
                onCustomize: () => _showCustomizeShortcutsModal(context),
              ),

              const SizedBox(height: 12),

              // 4. Today Center Meeting Schedule Card
              Padding(
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
                    padding: const EdgeInsets.all(14.0),
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
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryNavy.withAlpha(15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.groups_outlined,
                                      size: 14,
                                      color: AppTheme.primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l10n.todayCenterMeeting,
                                      style: const TextStyle(
                                        fontSize: 13,
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
                              onTap: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(1);
                                } else {
                                  context.push(AppRouter.centersRoute);
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
                                        color: AppTheme.accentEmerald,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.accentEmerald),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildCenterMeetingRow(
                          context,
                          code: 'C001',
                          name: 'Taunggyi Central Center',
                          time: '09:00 AM • 15 ${l10n.membersCount}',
                          collectedText: '${l10n.collectedLabel}: 850,000 MMK (85%)',
                          statusColor: AppTheme.accentEmerald,
                          collectLabel: l10n.collectPayment,
                          onCollect: () {
                            context.push('${AppRouter.collectionRoute}?centerCode=C001&centerName=${Uri.encodeComponent("Taunggyi Central Center")}');
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildCenterMeetingRow(
                          context,
                          code: 'C002',
                          name: 'Ayetharyar Solidarity Group',
                          time: '02:00 PM • 12 ${l10n.membersCount}',
                          collectedText: '${l10n.pendingLabel} • ${l10n.expectedLabel} 400,000 MMK',
                          statusColor: AppTheme.accentOrange,
                          collectLabel: l10n.collectPayment,
                          onCollect: () {
                            context.push('${AppRouter.collectionRoute}?centerCode=C002&centerName=${Uri.encodeComponent("Ayetharyar Solidarity Group")}');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Cash in Hand & Quick Vault Handover Card
              Padding(
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
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.accentOrange, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cashInHand,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.formatMmk(850000),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(100, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.qr_code_2, size: 16),
                          label: Text(l10n.handoverButton, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _showHandoverModal(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterMeetingRow(
    BuildContext context, {
    required String code,
    required String name,
    required String time,
    required String collectedText,
    required Color statusColor,
    required String collectLabel,
    required VoidCallback onCollect,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.location_city_rounded, color: statusColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$code • $name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppTheme.primaryNavy),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 1),
                Text(
                  collectedText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryNavy,
              side: const BorderSide(color: AppTheme.primaryNavy, width: 1),
              minimumSize: const Size(64, 28),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: onCollect,
            child: Text(collectLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricChip({
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
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
