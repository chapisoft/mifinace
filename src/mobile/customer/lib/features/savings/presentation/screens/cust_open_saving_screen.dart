import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe High-Yield Deposit'),
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
                title: const Text('Passbook Opened!'),
                content: Text(
                  'Your ${state.newAccount.tenureMonths}-month deposit account ${state.newAccount.accountNumber} is active with balance ${CurrencyFormatter.formatMmk(state.newAccount.balanceMmk)}.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy),
                    child: const Text('View Passbooks'),
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
                  const Text(
                    'Select Deposit Tenure',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTenureChip(3, '3 Months', '12% p.a.'),
                      const SizedBox(width: 8),
                      _buildTenureChip(6, '6 Months', '13% p.a.'),
                      const SizedBox(width: 8),
                      _buildTenureChip(12, '12 Months', '14% p.a.'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Deposit Principal Amount (MMK)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: 'e.g. 50,000',
                      suffixText: 'MMK',
                    ),
                    validator: (v) {
                      final val = double.tryParse(v?.replaceAll(',', '') ?? '');
                      if (val == null || val < 10000) {
                        return 'Minimum deposit is 10,000 MMK';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Legal Beneficiary Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _beneficiaryController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Enter full legal name of heir / relative',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Beneficiary name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Profit Projection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CustomerTheme.secondaryAmber),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.trending_up, color: Color(0xFF92400E)),
                            SizedBox(width: 8),
                            Text(
                              'ESTIMATED MATURITY PROFIT',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Expected Profit at Maturity:', style: TextStyle(fontSize: 13)),
                            Text(
                              '+${CurrencyFormatter.formatMmk(_estimatedProfit)}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: isLoading ? null : _submitSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primaryNavy,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirm & Subscribe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? CustomerTheme.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? CustomerTheme.primaryNavy : CustomerTheme.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : CustomerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rate,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? CustomerTheme.secondaryAmber : CustomerTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitSubscription() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      context.read<SavingsBloc>().add(
            OpenSavingAccountRequested(
              memberNrc: widget.memberNrc,
              initialDepositMmk: amount,
              tenureMonths: _selectedTenureMonths,
              beneficiaryName: _beneficiaryController.text.trim(),
            ),
          );
    }
  }
}
