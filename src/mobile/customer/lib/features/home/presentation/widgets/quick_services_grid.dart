import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';

/// Quick services shortcuts grid for customer dashboard.
class QuickServicesGrid extends StatelessWidget {
  final VoidCallback onMmqrPay;
  final VoidCallback onLoanSchedule;
  final VoidCallback onSavings;
  final VoidCallback onInsurance;

  const QuickServicesGrid({
    super.key,
    required this.onMmqrPay,
    required this.onLoanSchedule,
    required this.onSavings,
    required this.onInsurance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomerTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildServiceItem(
                icon: Icons.qr_code_scanner,
                label: 'MMQR Pay',
                color: CustomerTheme.primaryNavy,
                onTap: onMmqrPay,
              ),
              const SizedBox(width: 12),
              _buildServiceItem(
                icon: Icons.calendar_month,
                label: 'Schedules',
                color: const Color(0xFF2563EB),
                onTap: onLoanSchedule,
              ),
              const SizedBox(width: 12),
              _buildServiceItem(
                icon: Icons.savings,
                label: 'Savings',
                color: CustomerTheme.secondaryAmber,
                onTap: onSavings,
              ),
              const SizedBox(width: 12),
              _buildServiceItem(
                icon: Icons.health_and_safety,
                label: 'Insurance',
                color: const Color(0xFF10B981),
                onTap: onInsurance,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
