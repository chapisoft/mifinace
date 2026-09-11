import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';

class CustomerNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  const CustomerNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

/// Notification Center screen for borrower reminders and payment confirmations.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      CustomerNotification(
        title: 'Upcoming Repayment Due',
        message: 'Installment #5 for loan AGRI-KYA-001 is due in 2 days. Pay via MMQR to keep an active credit score.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.alarm,
        iconColor: CustomerTheme.secondaryAmber,
      ),
      CustomerNotification(
        title: 'Payment Received',
        message: 'Installment #4 (48,000 MMK) was successfully settled via KBZPay MMQR. Ref: BMF-TX-98210.',
        timestamp: DateTime.now().subtract(const Duration(days: 28)),
        icon: Icons.check_circle,
        iconColor: CustomerTheme.statusCurrent,
        isRead: true,
      ),
      CustomerNotification(
        title: 'Monthly Savings Interest Credited',
        message: '+4,800 MMK interest was added to your compulsory savings passbook BMF-SAV-098231.',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        icon: Icons.savings,
        iconColor: const Color(0xFF0D9488),
        isRead: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final n = notifications[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tileColor: n.isRead ? Colors.transparent : const Color(0xFFF0FDF4),
            leading: CircleAvatar(
              backgroundColor: n.iconColor.withAlpha(25),
              child: Icon(n.icon, color: n.iconColor),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${n.timestamp.day}/${n.timestamp.month}',
                  style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                n.message,
                style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
