import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.savings_outlined, color: AppTheme.accentTeal, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l10n.depositTitle}: ${widget.account.customerName}',
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
                        Text(l10n.currentBalanceLabel, style: const TextStyle(fontSize: 13)),
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
                decoration: InputDecoration(
                  labelText: l10n.depositAmountLabel,
                  hintText: l10n.depositAmountHint,
                  prefixIcon: const Icon(Icons.money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.depositAmountRequired;
                  }
                  final parsed = double.tryParse(val.replaceAll(',', ''));
                  if (parsed == null || parsed < 1000) {
                    return l10n.minDepositValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.printReceiptCheckbox, style: const TextStyle(fontSize: 13)),
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
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentTeal,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.check, size: 18),
          label: Text(l10n.confirmDeposit),
          onPressed: _submit,
        ),
      ],
    );
  }
}
