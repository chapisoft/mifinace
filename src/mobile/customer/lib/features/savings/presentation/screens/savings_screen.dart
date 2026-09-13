import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';
import '../widgets/saving_card.dart';

/// Screen listing borrower savings accounts with daily accrued profit and open deposit button.
class SavingsScreen extends StatefulWidget {
  final String memberNrc;

  const SavingsScreen({super.key, required this.memberNrc});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  void _loadSavings() {
    context.read<SavingsBloc>().add(LoadSavingsAccountsRequested(widget.memberNrc));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savingsAndPassbooks, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
            onPressed: _loadSavings,
          ),
        ],
      ),
      body: BlocBuilder<SavingsBloc, SavingsState>(
        builder: (context, state) {
          if (state is SavingsLoading) {
            return const Center(child: CircularProgressIndicator(color: CustomerTheme.primaryNavy));
          } else if (state is SavingsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 54, color: CustomerTheme.accentCrimson),
                    const SizedBox(height: 16),
                    Text(state.errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadSavings,
                      style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is SavingsLoaded) {
            final accounts = state.accounts;

            return RefreshIndicator(
              color: CustomerTheme.primaryNavy,
              onRefresh: () async => _loadSavings(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Savings & Interest Summary Header
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF065F46),
                            Color(0xFF0D9488),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF065F46).withAlpha(60),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.savings_outlined, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.totalSavingsMetric.toUpperCase(),
                                style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CurrencyFormatter.formatMmk(state.totalSavingsBalanceMmk),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.accruedInterest,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                Text(
                                  '+${CurrencyFormatter.formatMmk(state.totalAccruedInterestMmk)}',
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.savingsAndPassbooks,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                          ),
                          Text(
                            '${accounts.length}',
                            style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        return SavingCard(account: accounts[index]);
                      },
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/savings/open', extra: widget.memberNrc),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.openSavingOnline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
