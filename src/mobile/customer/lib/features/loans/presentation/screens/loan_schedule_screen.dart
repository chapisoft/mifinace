import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule: ${widget.loan.contractCode}'),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.loan.debtGroup.badgeColor,
                        borderRadius: BorderRadius.circular(8),
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
                        const Text(
                          'Disbursed Principal',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
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
                        const Text(
                          'Remaining Principal',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
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
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CustomerTheme.primaryNavy),
                    ),
                  );
                } else if (state is LoanError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 54, color: CustomerTheme.accentCrimson),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, color: CustomerTheme.textPrimary),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetchSchedule,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomerTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is LoanScheduleLoaded) {
                  final schedules = state.schedules;
                  if (schedules.isEmpty) {
                    return const Center(
                      child: Text(
                        'No installment schedule records found.',
                        style: TextStyle(color: CustomerTheme.textSecondary),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: CustomerTheme.primaryNavy,
                    onRefresh: () async => _fetchSchedule(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        return ScheduleItemWidget(item: schedules[index]);
                      },
                    ),
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
