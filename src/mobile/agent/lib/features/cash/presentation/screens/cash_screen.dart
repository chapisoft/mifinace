import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/cash_transaction_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/cash_bloc.dart';
import '../bloc/cash_event.dart';
import '../bloc/cash_state.dart';
import '../widgets/qr_handover_dialog.dart';

/// Screen for field credit officers to monitor real-time cash balance, safety limit, and branch vault handover.
class CashScreen extends StatefulWidget {
  final String officerId;

  const CashScreen({
    super.key,
    this.officerId = 'OFFICER001',
  });

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CashBloc>().add(LoadCashSummaryRequested(officerId: widget.officerId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cashManagementTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CashBloc>().add(LoadCashSummaryRequested(officerId: widget.officerId));
            },
          ),
        ],
      ),
      body: BlocConsumer<CashBloc, CashState>(
        listener: (context, state) {
          if (state is CashHandoverQrGeneratedState) {
            showDialog(
              context: context,
              builder: (ctx) => QrHandoverDialog(
                summary: state.summary,
                qrPayload: state.qrPayload,
                onHandoverConfirmed: () {
                  context.read<CashBloc>().add(
                        ConfirmHandoverCompletedRequested(
                          officerId: widget.officerId,
                          referenceId: 'REF-VAULT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        ),
                      );
                },
              ),
            );
          } else if (state is CashHandoverSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.cashHandoverSuccess} (Ref: ${state.referenceId})'),
                backgroundColor: AppTheme.accentTeal,
              ),
            );
          } else if (state is CashError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppTheme.accentCrimson),
            );
          }
        },
        builder: (context, state) {
          if (state is CashLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CashLoaded || state is CashHandoverQrGeneratedState) {
            final summary = state is CashLoaded
                ? state.summary
                : (state as CashHandoverQrGeneratedState).summary;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Warning Banner if exceeding safe limit
                if (summary.isExceedingLimit)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCrimson.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accentCrimson),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.accentCrimson, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.safetyLimitExceeded,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCrimson, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.safetyLimitWarning} (${CurrencyFormatter.formatMmk(summary.safeLimitMmk)})',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Cash In Hand Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          l10n.currentCashInHand,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatMmk(summary.currentCashBalanceMmk),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: summary.isExceedingLimit ? AppTheme.accentCrimson : AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNavy.withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(l10n.loanRepayments, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      CurrencyFormatter.formatMmk(summary.totalRepaymentMmk),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(l10n.savingsDeposits, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      CurrencyFormatter.formatMmk(summary.totalSavingMmk),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.qr_code_2),
                          label: Text(l10n.handoverToBranch, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: summary.currentCashBalanceMmk > 0
                              ? () {
                                  context.read<CashBloc>().add(GenerateHandoverQrRequested(officerId: widget.officerId));
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  l10n.todayCashTransactions,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 10),

                // Transactions List
                if (summary.entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(l10n.noCashTransactions, style: const TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: summary.entries.length,
                    itemBuilder: (ctx, index) {
                      final entry = summary.entries[index];
                      final isHandover = entry.transactionType == CashTransactionType.handoverToCashier;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isHandover ? AppTheme.accentCrimson.withAlpha(20) : AppTheme.accentTeal.withAlpha(20),
                            child: Icon(
                              isHandover ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isHandover ? AppTheme.accentCrimson : AppTheme.accentTeal,
                              size: 18,
                            ),
                          ),
                          title: Text(entry.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(
                            '${entry.transactionType.localizedName(l10n)} • Ref: ${entry.referenceId}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          trailing: Text(
                            '${isHandover ? "-" : "+"}${CurrencyFormatter.formatMmk(entry.amountMmk)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isHandover ? AppTheme.accentCrimson : AppTheme.accentTeal,
                            ),
                          ),
                        ),
                      );
                    },
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
