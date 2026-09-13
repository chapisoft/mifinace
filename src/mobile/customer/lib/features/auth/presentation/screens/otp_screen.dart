import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/customer_theme.dart';
import '../../../../core/l10n/customer_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Màn hình nhập mã OTP xác thực kích hoạt hoặc đặt lại mã PIN.
class OtpScreen extends StatefulWidget {
  final String identifier;
  final String maskedPhone;
  final String purpose; // 'ACTIVATION' | 'RESET_PIN'

  const OtpScreen({
    super.key,
    required this.identifier,
    required this.maskedPhone,
    this.purpose = 'ACTIVATION',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      final l10n = CustomerLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enter6DigitPin),
          backgroundColor: CustomerTheme.accentCrimson,
        ),
      );
      return;
    }

    if (widget.purpose == 'ACTIVATION') {
      context.read<CustomerAuthBloc>().add(
            VerifyActivationOtpRequested(
              identifier: widget.identifier,
              otpCode: code,
            ),
          );
    } else {
      context.read<CustomerAuthBloc>().add(
            VerifyForgotPinOtpRequested(
              identifier: widget.identifier,
              otpCode: code,
            ),
          );
    }
  }

  void _resendOtp() {
    if (_resendCountdown > 0) return;
    if (widget.purpose == 'ACTIVATION') {
      context.read<CustomerAuthBloc>().add(
            SendActivationOtpRequested(identifier: widget.identifier),
          );
    } else {
      context.read<CustomerAuthBloc>().add(
            SendForgotPinOtpRequested(identifier: widget.identifier),
          );
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final titleText = l10n.otpTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is AuthActivationOtpVerifiedState) {
            context.push(
              AppRouter.setPinRoute,
              extra: {
                'token': state.stepUpToken,
                'purpose': 'ACTIVATION',
              },
            );
          } else if (state is AuthForgotPinOtpVerifiedState) {
            context.push(
              AppRouter.setPinRoute,
              extra: {
                'token': state.resetPinToken,
                'purpose': 'RESET_PIN',
              },
            );
          } else if (state is AuthError) {
            final cleanMsg = state.errorMessage.replaceAll('Exception: ', '').trim();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(cleanMsg),
                backgroundColor: CustomerTheme.accentCrimson,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.mark_email_read_outlined, size: 64, color: CustomerTheme.secondaryAmber),
                const SizedBox(height: 16),
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.maskedPhone.isNotEmpty ? widget.maskedPhone : widget.identifier,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                // OTP Field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(l10n.verifyOtp, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: _resendCountdown == 0 ? _resendOtp : null,
                    child: Text(
                      _resendCountdown > 0 ? '${l10n.retry} (${_resendCountdown}s)' : l10n.requestOtp,
                      style: TextStyle(
                        color: _resendCountdown > 0 ? CustomerTheme.textSecondary : CustomerTheme.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
