import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';
import 'package:bmf_customer/features/loans/presentation/widgets/loan_card.dart';

/// Screen listing active and historical loan contracts for the borrower.
class LoanListScreen extends StatefulWidget {
  final String memberNrc;

  const LoanListScreen({super.key, required this.memberNrc});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }

  void _fetchLoans() {
    context.read<CustomerLoanBloc>().add(LoadActiveLoansRequested(widget.memberNrc));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans & Contracts'),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchLoans,
          ),
        ],
      ),
      body: BlocBuilder<CustomerLoanBloc, CustomerLoanState>(
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
                      onPressed: _fetchLoans,
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
          } else if (state is LoanListLoaded) {
            final loans = state.loans;
            if (loans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: CustomerTheme.textSecondary.withAlpha(120)),
                      const SizedBox(height: 16),
                      const Text(
                        'No Active Loans Found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You currently have no active credit contracts. Contact your village credit officer to apply.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: CustomerTheme.primaryNavy,
              onRefresh: () async => _fetchLoans(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return LoanCard(
                    loan: loan,
                    onViewSchedule: () {
                      context.push(AppRouter.loanScheduleRoute, extra: loan);
                    },
                    onPayNow: () {
                      context.push(
                        AppRouter.paymentQrRoute,
                        extra: {
                          'contractCode': loan.contractCode,
                          'amountMmk': loan.nextDueAmountMmk > 0 ? loan.nextDueAmountMmk : 48000.0,
                        },
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showPayNowDialog(BuildContext context, dynamic loan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_2, color: CustomerTheme.primaryNavy, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Repay Loan: ${loan.contractCode}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select payment channel to settle installment:',
                  style: TextStyle(fontSize: 14, color: CustomerTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(Icons.qr_code_scanner, color: CustomerTheme.primaryNavy),
                  ),
                  title: const Text('MMQR Dynamic Code (National Standard)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Scan & pay instantly via any banking app'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('MMQR Gateway integration ready for Sprint 11')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.account_balance_wallet, color: CustomerTheme.secondaryAmber),
                  ),
                  title: const Text('Mobile Wallets (KBZPay, WavePay)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Deep-link direct app transfer'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('KBZPay / WavePay integration ready for Sprint 11')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
