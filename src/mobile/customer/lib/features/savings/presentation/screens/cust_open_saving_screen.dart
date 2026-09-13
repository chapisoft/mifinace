import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';

/// Screen allowing borrowers to subscribe to high-yield fixed-term savings online.
class CustOpenSavingScreen extends StatefulWidget {
  final String memberNrc;

  const CustOpenSavingScreen({super.key, required this.memberNrc});

  @override
  State<CustOpenSavingScreen> createState() => _CustOpenSavingScreenState();
}

class _CustOpenSavingScreenState extends State<CustOpenSavingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '50000');
  final _beneficiaryController = TextEditingController();

  int _selectedTenureMonths = 12;

  double get _currentRate {
    switch (_selectedTenureMonths) {
      case 3:
        return 12.0;
      case 6:
        return 13.0;
      case 12:
        return 14.0;
      default:
        return 12.0;
    }
  }

  double get _estimatedProfit {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    return amount * (_currentRate / 100.0) * (_selectedTenureMonths / 12.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openSavingsPassbookTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SavingsBloc, SavingsState>(
        listener: (context, state) {
          if (state is SavingAccountOpenedSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(l10n.passbookOpenedSuccess, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                content: Text(
                  '${l10n.referenceNo}: ${state.newAccount.accountNumber}\n${l10n.depositPrincipal}: ${CurrencyFormatter.formatMmk(state.newAccount.balanceMmk)}',
                  style: const TextStyle(fontSize: 13),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy, foregroundColor: Colors.white),
                    child: Text(l10n.viewPassbooks),
                  ),
                ],
              ),
            );
          } else if (state is SavingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: CustomerTheme.accentCrimson),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SavingsLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fixedTermSaving,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTenureChip(3, '3 Mos', '12%'),
                      const SizedBox(width: 8),
                      _buildTenureChip(6, '6 Mos', '13%'),
                      const SizedBox(width: 8),
                      _buildTenureChip(12, '12 Mos', '14%'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.depositPrincipal,
                      prefixIcon: const Icon(Icons.savings_outlined),
                      suffixText: 'MMK',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final val = double.tryParse(v?.replaceAll(',', '') ?? '') ?? 0;
                      if (val < 10000) return 'Min: 10,000 MMK';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _beneficiaryController,
                    decoration: InputDecoration(
                      labelText: l10n.welcomeMember,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profit Projection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CustomerTheme.statusCurrent.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CustomerTheme.statusCurrent.withAlpha(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.interestRatePerAnnum, style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary)),
                            Text('$_currentRate% / yr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CustomerTheme.statusCurrent)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.expectedProfitAtMaturity, style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary)),
                            Text(
                              '+${CurrencyFormatter.formatMmk(_estimatedProfit)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CustomerTheme.statusCurrent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
                              context.read<SavingsBloc>().add(
                                    OpenSavingAccountRequested(
                                      memberNrc: widget.memberNrc,
                                      initialDepositMmk: amount,
                                      tenureMonths: _selectedTenureMonths,
                                      beneficiaryName: _beneficiaryController.text.trim(),
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.confirmAndSubscribe, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTenureChip(int months, String label, String rate) {
    final isSelected = _selectedTenureMonths == months;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTenureMonths = months),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? CustomerTheme.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? CustomerTheme.primaryNavy : CustomerTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Colors.white : CustomerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rate,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? CustomerTheme.secondaryAmber : CustomerTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
