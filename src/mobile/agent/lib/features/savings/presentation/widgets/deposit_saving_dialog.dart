import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/saving_account.dart';

/// Dialog allowing credit officers to record a field savings cash deposit.
class DepositSavingDialog extends StatefulWidget {
  final SavingAccount account;
  final Function(double amount, bool printReceipt) onConfirm;

  const DepositSavingDialog({
    super.key,
    required this.account,
    required this.onConfirm,
  });

  @override
  State<DepositSavingDialog> createState() => _DepositSavingDialogState();
}

class _DepositSavingDialogState extends State<DepositSavingDialog> {
  final _formKey = GlobalKey<FormState>();
  // Zero fake default values: amount controller starts empty
  final _amountController = TextEditingController();
  bool _printReceipt = true;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = CurrencyFormatter.parseMmk(_amountController.text).toDouble();
    Navigator.of(context).pop();
    widget.onConfirm(amount, _printReceipt);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.savings_outlined, color: AppTheme.accentTeal, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Deposit: ${widget.account.customerName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account: ${widget.account.accountNumber}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NRC: ${widget.account.nrcFormatted}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Balance:', style: TextStyle(fontSize: 13)),
                        Text(
                          CurrencyFormatter.formatMmk(widget.account.balanceMmk),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Deposit Amount (MMK) *',
                  hintText: 'Enter amount to deposit',
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deposit amount is required';
                  }
                  final parsed = double.tryParse(val.replaceAll(',', ''));
                  if (parsed == null || parsed < 1000) {
                    return 'Minimum deposit amount is 1,000 MMK';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Print receipt via Bluetooth printer', style: TextStyle(fontSize: 13)),
                value: _printReceipt,
                activeColor: AppTheme.primaryNavy,
                onChanged: (val) => setState(() => _printReceipt = val ?? true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentTeal,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Confirm Deposit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
