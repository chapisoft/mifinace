import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../bloc/payment_state.dart';

/// Screen celebrating instant loan settlement with digital receipt.
class PaymentSuccessScreen extends StatelessWidget {
  final PaymentSuccess paymentData;

  const PaymentSuccessScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.electronicReceipt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: CustomerTheme.statusCurrent.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 60,
                            color: CustomerTheme.statusCurrent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.paymentSuccess,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Electronic Receipt Box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CustomerTheme.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildReceiptRow(l10n.contractCodeLabel, paymentData.contractCode),
                            const Divider(height: 20),
                            _buildReceiptRow(l10n.transactionRefLabel, paymentData.transactionReference),
                            const Divider(height: 20),
                            _buildReceiptRow(l10n.paymentChannelLabel, 'MMQR / National Gateway'),
                            const Divider(height: 20),
                            _buildReceiptRow(l10n.settledDateLabel, '${paymentData.settledAt.day}/${paymentData.settledAt.month}/${paymentData.settledAt.year} ${paymentData.settledAt.hour}:${paymentData.settledAt.minute.toString().padLeft(2, '0')}'),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.totalPaidAmountLabel,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                                ),
                                Text(
                                  CurrencyFormatter.formatMmk(paymentData.amountMmk),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CustomerTheme.statusCurrent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action
              ElevatedButton(
                onPressed: () => context.go(AppRouter.homeRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.backToHome, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CustomerTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
