import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';
import 'package:bmf_customer/features/loans/presentation/widgets/schedule_item_widget.dart';

/// Screen displaying detailed multi-period repayment schedule for a specific loan contract.
class LoanScheduleScreen extends StatefulWidget {
  final CustomerLoan loan;

  const LoanScheduleScreen({super.key, required this.loan});

  @override
  State<LoanScheduleScreen> createState() => _LoanScheduleScreenState();
}

class _LoanScheduleScreenState extends State<LoanScheduleScreen> {
  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  void _fetchSchedule() {
    context.read<CustomerLoanBloc>().add(
          LoadLoanScheduleRequested(widget.loan.contractCode),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.scheduleTitle}: ${widget.loan.contractCode}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
            onPressed: _fetchSchedule,
          ),
        ],
      ),
      body: Column(
        children: [
          // Contract Summary Header Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: CustomerTheme.primaryNavy,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.loan.loanType.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.loan.debtGroup.badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.loan.debtGroup.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.principal,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatMmk(widget.loan.disbursedAmountMmk),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.outstandingLoanMetric,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatMmk(widget.loan.remainingPrincipalMmk),
                          style: const TextStyle(
                            color: CustomerTheme.secondaryAmber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: BlocBuilder<CustomerLoanBloc, CustomerLoanState>(
              builder: (context, state) {
                if (state is LoanLoading) {
                  return const Center(child: CircularProgressIndicator(color: CustomerTheme.primaryNavy));
                } else if (state is LoanError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(state.errorMessage, textAlign: TextAlign.center),
                    ),
                  );
                } else if (state is LoanScheduleLoaded) {
                  final schedules = state.schedules;
                  if (schedules.isEmpty) {
                    return Center(
                      child: Text(l10n.noRecentTransactions, style: const TextStyle(color: CustomerTheme.textSecondary)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return ScheduleItemWidget(item: schedule);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
