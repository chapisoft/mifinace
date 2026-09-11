import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/debt_group.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../../../core/enums/repayment_status.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/schedule_item.dart';
import '../bloc/collection_bloc.dart';
import '../bloc/collection_event.dart';
import '../bloc/collection_state.dart';
import '../widgets/collect_repayment_dialog.dart';

/// Screen displaying the Collection Sheet for a specific Center/Group.
class CollectionSheetScreen extends StatefulWidget {
  final String centerCode;
  final String centerName;
  final String groupCode;

  const CollectionSheetScreen({
    super.key,
    required this.centerCode,
    required this.centerName,
    this.groupCode = 'G001',
  });

  @override
  State<CollectionSheetScreen> createState() => _CollectionSheetScreenState();
}

class _CollectionSheetScreenState extends State<CollectionSheetScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Due Today, 2: Overdue, 3: Paid

  @override
  void initState() {
    super.initState();
    context.read<CollectionBloc>().add(LoadSchedulesRequested(widget.groupCode));
  }

  void _openCollectDialog(BuildContext context, ScheduleItem schedule) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CollectRepaymentDialog(
          schedule: schedule,
          onConfirm: (amount, method) {
            context.read<CollectionBloc>().add(
                  SubmitRepaymentRequested(
                    schedule: schedule,
                    amount: amount,
                    method: method,
                    collectorId: 'OFFICER001',
                  ),
                );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.collectionSheetTitle, style: const TextStyle(fontSize: 16)),
            Text(
              '${widget.centerCode} - ${widget.centerName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CollectionBloc>().add(LoadSchedulesRequested(widget.groupCode, forceRefresh: true));
            },
          ),
        ],
      ),
      body: BlocConsumer<CollectionBloc, CollectionState>(
        listener: (context, state) {
          if (state is RepaymentSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${l10n.collectionSuccessMessage}: ${CurrencyFormatter.formatMmk(state.receipt.totalAmount)} (${state.receipt.receiptNumber})',
                ),
                backgroundColor: AppTheme.accentTeal,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is CollectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.accentCrimson,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CollectionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.accentCrimson),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CollectionBloc>().add(LoadSchedulesRequested(widget.groupCode, forceRefresh: true));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CollectionLoaded) {
            final schedules = state.schedules;
            final double totalDue = state.totalDueAmount;
            final double totalCollected = state.totalCollectedAmount;

            // Filter logic
            final filteredList = schedules.where((item) {
              if (_selectedFilterIndex == 1) {
                return item.status == RepaymentStatus.pending;
              } else if (_selectedFilterIndex == 2) {
                return item.status == RepaymentStatus.overdue;
              } else if (_selectedFilterIndex == 3) {
                return item.status == RepaymentStatus.paidLocal ||
                    item.status == RepaymentStatus.synced ||
                    item.status == RepaymentStatus.settled;
              }
              return true;
            }).toList();

            return Column(
              children: [
                // Summary Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppTheme.primaryNavy,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryColumn(
                        label: l10n.todayTarget,
                        value: CurrencyFormatter.formatMmk(totalDue),
                        textColor: Colors.white,
                      ),
                      Container(height: 30, width: 1, color: Colors.white24),
                      _SummaryColumn(
                        label: l10n.collectedAmount,
                        value: CurrencyFormatter.formatMmk(totalCollected),
                        textColor: AppTheme.accentAmber,
                      ),
                      Container(height: 30, width: 1, color: Colors.white24),
                      _SummaryColumn(
                        label: l10n.memberCount,
                        value: '${schedules.length}',
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),

                // Filter Tabs
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: l10n.filterAll,
                          isSelected: _selectedFilterIndex == 0,
                          onTap: () => setState(() => _selectedFilterIndex = 0),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterDueToday,
                          isSelected: _selectedFilterIndex == 1,
                          onTap: () => setState(() => _selectedFilterIndex = 1),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterOverdue,
                          isSelected: _selectedFilterIndex == 2,
                          onTap: () => setState(() => _selectedFilterIndex = 2),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterPaid,
                          isSelected: _selectedFilterIndex == 3,
                          onTap: () => setState(() => _selectedFilterIndex = 3),
                        ),
                      ],
                    ),
                  ),
                ),

                // Schedules List
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text(
                            'No repayments found for current filter',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final schedule = filteredList[index];
                            return _ScheduleCard(
                              schedule: schedule,
                              onCollect: () => _openCollectDialog(context, schedule),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem schedule;
  final VoidCallback onCollect;

  const _ScheduleCard({
    required this.schedule,
    required this.onCollect,
  });

  Color _getDebtGroupColor(DebtGroup group) {
    switch (group) {
      case DebtGroup.standard:
        return AppTheme.accentTeal;
      case DebtGroup.watch:
        return AppTheme.accentAmber;
      case DebtGroup.substandard:
        return Colors.orange;
      case DebtGroup.doubtful:
        return Colors.deepOrange;
      case DebtGroup.loss:
        return AppTheme.accentCrimson;
    }
  }

  Widget _buildStatusBadge(RepaymentStatus status) {
    switch (status) {
      case RepaymentStatus.paidLocal:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.accentTeal),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync_problem, size: 12, color: AppTheme.accentTeal),
              SizedBox(width: 4),
              Text(
                'Paid (Offline Queue)',
                style: TextStyle(color: AppTheme.accentTeal, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case RepaymentStatus.synced:
      case RepaymentStatus.settled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 12, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'Paid (Synced)',
                style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case RepaymentStatus.overdue:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.accentCrimson.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.accentCrimson),
          ),
          child: const Text(
            'Overdue',
            style: TextStyle(color: AppTheme.accentCrimson, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withAlpha(20),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.primaryNavy),
          ),
          child: const Text(
            'Pending',
            style: TextStyle(color: AppTheme.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPaid = schedule.status == RepaymentStatus.paidLocal ||
        schedule.status == RepaymentStatus.synced ||
        schedule.status == RepaymentStatus.settled;

    final dateStr = schedule.dueDate.toIso8601String().substring(0, 10);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${schedule.contractCode} (Period ${schedule.periodNumber})',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(schedule.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDebtGroupColor(schedule.debtGroup).withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getDebtGroupColor(schedule.debtGroup)),
                  ),
                  child: Text(
                    schedule.debtGroup.code,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getDebtGroupColor(schedule.debtGroup),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.formatMmk(schedule.totalAmount),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due: $dateStr',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                if (!isPaid)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AppTheme.primaryNavy,
                    ),
                    icon: const Icon(Icons.payments, size: 14),
                    label: Text(l10n.collectPayment, style: const TextStyle(fontSize: 12)),
                    onPressed: onCollect,
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.print, size: 14),
                    label: Text(l10n.printReceipt, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.printingReceipt}: ${schedule.customerName}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
