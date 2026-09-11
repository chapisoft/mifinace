import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../collection/domain/entities/repayment_receipt.dart';
import '../../../printer/domain/services/bluetooth_printer_service.dart';
import '../../../printer/domain/services/receipt_renderer.dart';
import '../bloc/saving_bloc.dart';
import '../bloc/saving_event.dart';
import '../bloc/saving_state.dart';
import '../widgets/deposit_saving_dialog.dart';
import '../widgets/saving_account_card.dart';

/// Screen for field credit officers to search village savings accounts, record cash deposits, and print receipts.
class AgentSavingScreen extends StatefulWidget {
  final String? initialCenterCode;

  const AgentSavingScreen({
    super.key,
    this.initialCenterCode,
  });

  @override
  State<AgentSavingScreen> createState() => _AgentSavingScreenState();
}

class _AgentSavingScreenState extends State<AgentSavingScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SavingBloc>().add(LoadSavingAccountsRequested(
          centerCode: widget.initialCenterCode,
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SavingBloc>().add(LoadSavingAccountsRequested(
          centerCode: widget.initialCenterCode,
          query: query,
        ));
  }

  Future<void> _handleDepositReceiptPrint(BuildContext context, String customerName, String nrc, String accountNo, double amount, double newBalance) async {
    try {
      final printerService = context.read<BluetoothPrinterService>();
      final receipt = RepaymentReceipt(
        transactionId: 'TX-SAV-${DateTime.now().millisecondsSinceEpoch}',
        contractCode: accountNo,
        periodNumber: 1,
        customerCode: nrc,
        customerName: customerName,
        principalAmount: 0.0,
        interestAmount: 0.0,
        insuranceFee: 0.0,
        compulsorySaving: amount,
        totalAmount: amount,
        paymentMethod: RepaymentMethod.cash,
        receiptNumber: 'REC-SAV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        collectorId: 'OFFICER001',
        collectedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        idempotencyKey: 'IDEMP-SAV-${DateTime.now().millisecondsSinceEpoch}',
      );

      final receiptBytes = await MyanmarReceiptRenderer.renderReceiptToEscPosBytes(receipt: receipt);
      final success = await printerService.sendBytes(receiptBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Savings deposit receipt printed.' : 'Bluetooth printer not connected.'),
            backgroundColor: success ? AppTheme.accentTeal : AppTheme.accentAmber,
          ),
        );
      }
    } catch (_) {
      // Non-blocking print error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Savings Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Accounts',
            onPressed: () {
              context.read<SavingBloc>().add(LoadSavingAccountsRequested(
                    centerCode: widget.initialCenterCode,
                    query: _searchController.text,
                  ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by member name, NRC, or account...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderSubtle),

          // Accounts List with BlocConsumer
          Expanded(
            child: BlocConsumer<SavingBloc, SavingState>(
              listener: (context, state) {
                if (state is SavingDepositSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deposit of ${CurrencyFormatter.formatMmk(state.deposit.amountMmk)} recorded. New balance: ${CurrencyFormatter.formatMmk(state.deposit.newBalanceMmk)}',
                      ),
                      backgroundColor: AppTheme.accentTeal,
                    ),
                  );
                } else if (state is SavingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: AppTheme.accentCrimson,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SavingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SavingLoaded) {
                  if (state.accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.savings_outlined, size: 48, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          const Text(
                            'No savings accounts found.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Open First Account'),
                            onPressed: () {
                              context.push(AppRouter.openSavingRoute);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.accounts.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemBuilder: (ctx, index) {
                      final account = state.accounts[index];
                      return SavingAccountCard(
                        account: account,
                        onDeposit: () {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => DepositSavingDialog(
                              account: account,
                              onConfirm: (amount, printReceipt) {
                                context.read<SavingBloc>().add(
                                      DepositSavingRequested(
                                        accountNumber: account.accountNumber,
                                        customerName: account.customerName,
                                        amountMmk: amount,
                                        officerId: 'OFFICER001',
                                      ),
                                    );
                                if (printReceipt) {
                                  _handleDepositReceiptPrint(
                                    context,
                                    account.customerName,
                                    account.nrcFormatted,
                                    account.accountNumber,
                                    amount,
                                    account.balanceMmk + amount,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Open New Passbook'),
        onPressed: () {
          context.push(AppRouter.openSavingRoute);
        },
      ),
    );
  }
}
