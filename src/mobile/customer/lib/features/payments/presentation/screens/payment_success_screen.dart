import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../bloc/payment_state.dart';

/// Screen celebrating instant loan settlement with digital receipt.
class PaymentSuccessScreen extends StatelessWidget {
  final PaymentSuccess paymentData;

  const PaymentSuccessScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repayment Receipt'),
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
                      // Success Tick Icon with pulse effect
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: CustomerTheme.statusCurrent.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 64,
                            color: CustomerTheme.statusCurrent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Repayment Received!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your installment has been settled in Core Banking.',
                        style: TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
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
                              color: Colors.black.withAlpha(15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildReceiptRow('Contract Code', paymentData.contractCode),
                            const Divider(height: 24),
                            _buildReceiptRow('Transaction Ref', paymentData.transactionReference),
                            const Divider(height: 24),
                            _buildReceiptRow('Payment Channel', 'MMQR / National Gateway'),
                            const Divider(height: 24),
                            _buildReceiptRow('Settled Date', '${paymentData.settledAt.day}/${paymentData.settledAt.month}/${paymentData.settledAt.year} ${paymentData.settledAt.hour}:${paymentData.settledAt.minute.toString().padLeft(2, '0')}'),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Paid Amount',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
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

              // Bottom Actions
              ElevatedButton(
                onPressed: () => context.go(AppRouter.homeRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: CustomerTheme.textSecondary)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CustomerTheme.textPrimary),
        ),
      ],
    );
  }
}
