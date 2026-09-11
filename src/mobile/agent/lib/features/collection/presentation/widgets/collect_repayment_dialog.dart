import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/schedule_item.dart';

/// Dialog Form for collecting member repayments in the field.
class CollectRepaymentDialog extends StatefulWidget {
  final ScheduleItem schedule;
  final Function(double amount, RepaymentMethod method) onConfirm;

  const CollectRepaymentDialog({
    super.key,
    required this.schedule,
    required this.onConfirm,
  });

  @override
  State<CollectRepaymentDialog> createState() => _CollectRepaymentDialogState();
}

class _CollectRepaymentDialogState extends State<CollectRepaymentDialog> {
  late RepaymentMethod _selectedMethod;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _selectedMethod = RepaymentMethod.cash;
    _amountController = TextEditingController(
      text: CurrencyFormatter.formatNumber(widget.schedule.totalAmount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _getMethodLabel(AppLocalizations l10n, RepaymentMethod method) {
    switch (method) {
      case RepaymentMethod.cash:
        return l10n.methodCash;
      case RepaymentMethod.mmqr:
        return l10n.methodMmqr;
      case RepaymentMethod.kbzPay:
        return l10n.methodKbzPay;
      case RepaymentMethod.wavePay:
        return l10n.methodWavePay;
      case RepaymentMethod.ayaPay:
        return 'AYA Pay';
      case RepaymentMethod.mytelPay:
        return 'MytelPay';
      case RepaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.primaryNavy,
            radius: 16,
            child: Icon(Icons.payment, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${l10n.collectPayment}: ${widget.schedule.customerName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loan & Period Details Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  _DetailRow(label: l10n.contractCodeLabel, value: widget.schedule.contractCode),
                  _DetailRow(label: l10n.periodNumberLabel, value: '${widget.schedule.periodNumber}'),
                  const Divider(height: 16),
                  _DetailRow(label: l10n.principalLabel, value: CurrencyFormatter.formatMmk(widget.schedule.principalAmount)),
                  _DetailRow(label: l10n.interestLabel, value: CurrencyFormatter.formatMmk(widget.schedule.interestAmount)),
                  _DetailRow(label: l10n.insuranceLabel, value: CurrencyFormatter.formatMmk(widget.schedule.insuranceFee)),
                  if (widget.schedule.compulsorySaving > 0)
                    _DetailRow(label: l10n.savingLabel, value: CurrencyFormatter.formatMmk(widget.schedule.compulsorySaving)),
                  const Divider(height: 16),
                  _DetailRow(
                    label: l10n.totalDueLabel,
                    value: CurrencyFormatter.formatMmk(widget.schedule.totalAmount),
                    isBold: true,
                    valueColor: AppTheme.primaryNavy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Selector
            Text(
              l10n.paymentMethodLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RepaymentMethod>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: RepaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(_getMethodLabel(l10n, method)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton, style: const TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirm(widget.schedule.totalAmount, _selectedMethod);
          },
          child: Text(l10n.confirmCollectionButton),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
