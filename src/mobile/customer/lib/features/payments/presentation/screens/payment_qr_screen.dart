import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

/// Screen displaying dynamic EMVCo MMQR code and sleek quick-launch shortcuts for Myanmar mobile wallets.
class PaymentQrScreen extends StatefulWidget {
  final String contractCode;
  final double amountMmk;
  final VoidCallback? onOpenDrawer;

  const PaymentQrScreen({
    super.key,
    this.contractCode = '',
    this.amountMmk = 0.0,
    this.onOpenDrawer,
  });

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  Timer? _pollingTimer;
  String? _activeContractCode;
  double? _activeAmountMmk;

  @override
  void initState() {
    super.initState();
    _activeContractCode = widget.contractCode.isNotEmpty ? widget.contractCode : null;
    _activeAmountMmk = widget.amountMmk > 0 ? widget.amountMmk : null;
    _initPayment();
  }

  void _initPayment() {
    if (_activeContractCode != null && (_activeAmountMmk ?? 0) > 0) {
      context.read<PaymentBloc>().add(
            GenerateMmqrRequested(
              contractCode: _activeContractCode!,
              amountMmk: _activeAmountMmk!,
            ),
          );
    } else {
      // Trigger load loans if not provided
      final authState = context.read<CustomerAuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<CustomerLoanBloc>().add(LoadActiveLoansRequested(authState.profile.nrcFormatted));
      }
    }
  }

  void _startPolling(String txRef) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_activeContractCode != null && (_activeAmountMmk ?? 0) > 0) {
        context.read<PaymentBloc>().add(
              PollPaymentStatusRequested(
                transactionReference: txRef,
                contractCode: _activeContractCode!,
                amountMmk: _activeAmountMmk!,
              ),
            );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.mmqrRepaymentTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.onOpenDrawer,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is MmqrGenerated) {
            _startPolling(state.payment.transactionReference);
          } else if (state is PaymentSuccess) {
            _pollingTimer?.cancel();
            context.pushReplacement('/payment/success', extra: state);
          }
        },
        child: BlocBuilder<CustomerLoanBloc, CustomerLoanState>(
          builder: (context, loanState) {
            // If we don't have an active contract chosen yet, check active loans
            if (_activeContractCode == null) {
              if (loanState is LoanLoading) {
                return const Center(child: CircularProgressIndicator(color: CustomerTheme.primaryNavy));
              } else if (loanState is LoanListLoaded) {
                if (loanState.loans.isEmpty) {
                  return _buildNoActiveLoansState(l10n);
                }
                // If 1 loan, auto select and generate
                if (loanState.loans.length == 1) {
                  final singleLoan = loanState.loans.first;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _activeContractCode = singleLoan.contractCode;
                        _activeAmountMmk = singleLoan.nextDueAmountMmk > 0 ? singleLoan.nextDueAmountMmk : singleLoan.remainingPrincipalMmk;
                      });
                      _initPayment();
                    }
                  });
                  return const Center(child: CircularProgressIndicator(color: CustomerTheme.primaryNavy));
                }
                // If multiple loans, let user pick
                return _buildLoanSelector(loanState.loans, l10n);
              }
            }

            return BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, paymentState) {
                if (paymentState is PaymentLoading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(CustomerTheme.primaryNavy)),
                        const SizedBox(height: 14),
                        Text(l10n.generatingMmqr, style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                } else if (paymentState is PaymentFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 52, color: CustomerTheme.accentCrimson),
                          const SizedBox(height: 14),
                          Text(paymentState.errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5)),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _initPayment,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(l10n.retry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomerTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (paymentState is MmqrGenerated) {
                  return _buildMmqrContent(paymentState, l10n);
                }

                // Fallback initial
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: CustomerTheme.primaryNavy),
                      const SizedBox(height: 14),
                      Text(l10n.generatingMmqr, style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoActiveLoansState(CustomerLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomerTheme.primaryNavy.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, size: 48, color: CustomerTheme.primaryNavy),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveLoansToRepay,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CustomerTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.menuLoansSubtitle,
              style: const TextStyle(fontSize: 12.5, color: CustomerTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanSelector(List<CustomerLoan> loans, CustomerLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectLoanToRepay,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CustomerTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final loan = loans[index];
              final dueAmount = loan.nextDueAmountMmk > 0 ? loan.nextDueAmountMmk : loan.remainingPrincipalMmk;
              return InkWell(
                onTap: () {
                  setState(() {
                    _activeContractCode = loan.contractCode;
                    _activeAmountMmk = dueAmount;
                  });
                  _initPayment();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CustomerTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: CustomerTheme.primaryNavy.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: CustomerTheme.primaryNavy, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loan.contractCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dueMetric}: ${CurrencyFormatter.formatMmk(dueAmount)}',
                              style: const TextStyle(fontSize: 12, color: CustomerTheme.accentCrimson, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: CustomerTheme.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMmqrContent(MmqrGenerated state, CustomerLocalizations l10n) {
    final payment = state.payment;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Amount & Contract Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CustomerTheme.borderSubtle),
            ),
            child: Column(
              children: [
                Text(
                  l10n.dueMetric,
                  style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatMmk(payment.amountMmk),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomerTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.contractCodeLabel}: ${payment.contractCode}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: CustomerTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Dynamic QR Code Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomerTheme.borderSubtle),
            ),
            child: Column(
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CustomerTheme.primaryNavy, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 170,
                      color: CustomerTheme.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CustomerTheme.secondaryAmber.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'National MMQR (CBM)',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.menuMmqrSubtitle,
                  style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sleek Wallet Shortcut Grid
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.openWallet,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildWalletPill(
                label: 'KBZPay',
                color: const Color(0xFF0038A8),
                icon: Icons.account_balance_wallet_rounded,
                onTap: () {
                  context.read<PaymentBloc>().add(
                        LaunchWalletRequested(
                          walletScheme: 'kbzpay://qrpay?qrdata=${Uri.encodeComponent(payment.mmqrPayload)}',
                          mmqrPayload: payment.mmqrPayload,
                        ),
                      );
                },
              ),
              const SizedBox(width: 8),
              _buildWalletPill(
                label: 'WavePay',
                color: const Color(0xFFF59E0B),
                icon: Icons.waves_rounded,
                onTap: () {
                  context.read<PaymentBloc>().add(
                        LaunchWalletRequested(
                          walletScheme: 'wavepay://pay?qr=${Uri.encodeComponent(payment.mmqrPayload)}',
                          mmqrPayload: payment.mmqrPayload,
                        ),
                      );
                },
              ),
              const SizedBox(width: 8),
              _buildWalletPill(
                label: 'AYA Pay',
                color: const Color(0xFFDC2626),
                icon: Icons.payments_rounded,
                onTap: () {
                  context.read<PaymentBloc>().add(
                        LaunchWalletRequested(
                          walletScheme: 'ayapay://qrpayment?data=${Uri.encodeComponent(payment.mmqrPayload)}',
                          mmqrPayload: payment.mmqrPayload,
                        ),
                      );
                },
              ),
              const SizedBox(width: 8),
              _buildWalletPill(
                label: 'MytelPay',
                color: const Color(0xFFEA580C),
                icon: Icons.phone_android_rounded,
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
        ],
      ),
    );
  }

  Widget _buildWalletPill({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CustomerTheme.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withAlpha(25),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

