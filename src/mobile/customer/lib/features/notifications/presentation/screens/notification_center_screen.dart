import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';

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
  final List<CustomerNotification> notifications;

  const NotificationCenterScreen({
    super.key,
    this.notifications = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationCenterTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 56,
                      color: CustomerTheme.textSecondary.withAlpha(100),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.noNotifications,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CustomerTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.noNotificationsFound,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CustomerTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
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
                            fontSize: 13.5,
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
                      style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
