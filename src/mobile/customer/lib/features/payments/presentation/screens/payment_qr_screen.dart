import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

/// Screen displaying dynamic EMVCo MMQR code and deep link shortcuts for major Myanmar mobile wallets.
class PaymentQrScreen extends StatefulWidget {
  final String contractCode;
  final double amountMmk;

  const PaymentQrScreen({
    super.key,
    required this.contractCode,
    required this.amountMmk,
  });

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  void _initPayment() {
    context.read<PaymentBloc>().add(
          GenerateMmqrRequested(
            contractCode: widget.contractCode,
            amountMmk: widget.amountMmk,
          ),
        );
  }

  void _startPolling(String txRef) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      context.read<PaymentBloc>().add(
            PollPaymentStatusRequested(
              transactionReference: txRef,
              contractCode: widget.contractCode,
              amountMmk: widget.amountMmk,
            ),
          );
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MMQR Digital Repayment'),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is MmqrGenerated) {
            _startPolling(state.payment.transactionReference);
          } else if (state is PaymentSuccess) {
            _pollingTimer?.cancel();
            context.pushReplacement('/payment/success', extra: state);
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(CustomerTheme.primaryNavy)),
                  SizedBox(height: 16),
                  Text('Generating CBM standard dynamic MMQR...', style: TextStyle(color: CustomerTheme.textSecondary)),
                ],
              ),
            );
          } else if (state is PaymentFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 54, color: CustomerTheme.accentCrimson),
                    const SizedBox(height: 16),
                    Text(state.errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _initPayment,
                      style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is MmqrGenerated) {
            final payment = state.payment;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Amount to pay box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Repayment Amount Due',
                          style: TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatMmk(payment.amountMmk),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CustomerTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contract: ${payment.contractCode}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CustomerTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dynamic QR Frame
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: CustomerTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        // QR Code Graphic Area
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: CustomerTheme.primaryNavy, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.qr_code_2,
                              size: 190,
                              color: CustomerTheme.primaryNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: CustomerTheme.secondaryAmber.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'National MMQR (CBM)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan with any Myanmar banking or wallet app',
                          style: TextStyle(fontSize: 12, color: CustomerTheme.textSecondary.withAlpha(200)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Deep link Wallet Buttons
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Or Open Wallet Directly',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildWalletButton(
                        label: 'KBZPay',
                        color: const Color(0xFF0038A8), // KBZ Blue
                        icon: Icons.account_balance_wallet,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                                LaunchWalletRequested(
                                  walletScheme: 'kbzpay://qrpay?qrdata=${Uri.encodeComponent(payment.mmqrPayload)}',
                                  mmqrPayload: payment.mmqrPayload,
                                ),
                              );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildWalletButton(
                        label: 'WavePay',
                        color: const Color(0xFFF59E0B), // Wave Yellow
                        icon: Icons.waves,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                                LaunchWalletRequested(
                                  walletScheme: 'wavepay://pay?qr=${Uri.encodeComponent(payment.mmqrPayload)}',
                                  mmqrPayload: payment.mmqrPayload,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildWalletButton(
                        label: 'AYA Pay',
                        color: const Color(0xFFDC2626), // AYA Red
                        icon: Icons.payments,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                                LaunchWalletRequested(
                                  walletScheme: 'ayapay://qrpayment?data=${Uri.encodeComponent(payment.mmqrPayload)}',
                                  mmqrPayload: payment.mmqrPayload,
                                ),
                              );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildWalletButton(
                        label: 'MytelPay',
                        color: const Color(0xFFEA580C), // Mytel Orange
                        icon: Icons.phone_android,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                                LaunchWalletRequested(
                                  walletScheme: 'mytelpay://pay?qr=${Uri.encodeComponent(payment.mmqrPayload)}',
                                  mmqrPayload: payment.mmqrPayload,
                                ),
                              );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Simulated Manual Settle Button (for developer test & demo convenience)
                  OutlinedButton.icon(
                    onPressed: () {
                      final repo = context.read<PaymentBloc>();
                      repo.add(PollPaymentStatusRequested(
                        transactionReference: payment.transactionReference,
                        contractCode: payment.contractCode,
                        amountMmk: payment.amountMmk,
                      ));
                      // Trigger mock settlement directly
                      (context.read<PaymentBloc>()).emit(
                        PaymentSuccess(
                          transactionReference: payment.transactionReference,
                          contractCode: payment.contractCode,
                          amountMmk: payment.amountMmk,
                          settledAt: DateTime.now(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Simulate Webhook Settlement'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomerTheme.statusCurrent,
                      side: const BorderSide(color: CustomerTheme.statusCurrent),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWalletButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
