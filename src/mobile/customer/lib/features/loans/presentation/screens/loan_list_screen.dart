import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';
import 'package:bmf_customer/features/loans/presentation/widgets/loan_card.dart';

/// Screen listing active and historical loan contracts for the borrower.
class LoanListScreen extends StatefulWidget {
  final String memberNrc;
  final VoidCallback? onOpenDrawer;

  const LoanListScreen({
    super.key,
    this.memberNrc = '',
    this.onOpenDrawer,
  });

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
    final authState = context.read<CustomerAuthBloc>().state;
    final nrc = widget.memberNrc.isNotEmpty
        ? widget.memberNrc
        : (authState is AuthAuthenticated ? authState.profile.nrcFormatted : '');
    if (nrc.isNotEmpty) {
      context.read<CustomerLoanBloc>().add(LoadActiveLoansRequested(nrc));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.loansTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.onOpenDrawer,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
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
                      style: const TextStyle(fontSize: 14, color: CustomerTheme.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchLoans,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: CustomerTheme.textSecondary.withAlpha(100)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.activeLoans,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.menuLoansSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _fetchLoans(),
              color: CustomerTheme.primaryNavy,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                          'amountMmk': loan.nextDueAmountMmk > 0 ? loan.nextDueAmountMmk : loan.remainingPrincipalMmk,
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
}
