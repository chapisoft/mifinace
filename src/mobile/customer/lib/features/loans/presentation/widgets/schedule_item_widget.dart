import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/enums/repayment_status.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_schedule_item.dart';

/// Widget displaying a single installment in the customer loan repayment schedule.
class ScheduleItemWidget extends StatelessWidget {
  final CustomerScheduleItem item;

  const ScheduleItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (item.status) {
      case RepaymentStatus.paid:
        statusColor = CustomerTheme.statusCurrent;
        statusText = 'Paid (${item.paidDate?.day}/${item.paidDate?.month})';
        statusIcon = Icons.check_circle;
        break;
      case RepaymentStatus.dueToday:
        statusColor = CustomerTheme.secondaryAmber;
        statusText = 'Due Today';
        statusIcon = Icons.error_outline;
        break;
      case RepaymentStatus.overdue:
        statusColor = CustomerTheme.accentCrimson;
        statusText = 'Overdue (${item.overdueDays}d)';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case RepaymentStatus.upcoming:
        statusColor = CustomerTheme.textSecondary;
        statusText = 'Upcoming';
        statusIcon = Icons.schedule;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: item.status == RepaymentStatus.dueToday ? CustomerTheme.secondaryAmber : CustomerTheme.borderSubtle,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withAlpha(25),
                      radius: 14,
                      child: Text(
                        '${item.periodNumber}',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Period #${item.periodNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          'Due: ${item.dueDate.day}/${item.dueDate.month}/${item.dueDate.year}',
                          style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SubAmountText(label: 'Principal', amount: item.principalDueMmk),
                _SubAmountText(label: 'Interest', amount: item.interestDueMmk),
                _SubAmountText(label: 'Saving Fee', amount: item.savingFeeMmk),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Installment', style: TextStyle(fontSize: 10, color: CustomerTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatMmk(item.totalDueMmk),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
                    ),
                  ],
                ),
              ],
            ),
            if (item.transactionId != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CustomerTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Receipt Ref: ${item.transactionId}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: CustomerTheme.primaryNavy),
                    ),
                    Text(
                      'Method: ${item.paymentMethod ?? "CASH"}',
                      style: const TextStyle(fontSize: 10, color: CustomerTheme.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubAmountText extends StatelessWidget {
  final String label;
  final double amount;

  const _SubAmountText({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: CustomerTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.formatMmk(amount).replaceAll(' MMK', ''),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CustomerTheme.textPrimary),
        ),
      ],
    );
  }
}
