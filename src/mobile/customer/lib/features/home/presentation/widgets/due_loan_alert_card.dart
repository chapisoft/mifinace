import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';

/// Alert banner displayed on Home when an installment is due within 3 days or overdue.
class DueLoanAlertCard extends StatelessWidget {
  final CustomerLoan loan;
  final VoidCallback onPayNow;

  const DueLoanAlertCard({
    super.key,
    required this.loan,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Warm Amber Light
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomerTheme.secondaryAmber, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: CustomerTheme.secondaryAmber.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: CustomerTheme.secondaryAmber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Upcoming Installment Due Soon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Loan contract ${loan.contractCode} has a scheduled repayment due in ${loan.daysUntilDue} days.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF78350F)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due Amount',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatMmk(loan.nextDueAmountMmk),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CustomerTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onPayNow,
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('Pay via MMQR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
