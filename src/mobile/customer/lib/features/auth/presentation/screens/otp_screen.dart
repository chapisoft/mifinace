import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/customer_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Screen for verifying 6-digit SMS OTP sent to borrower phone.
class OtpScreen extends StatefulWidget {
  final String nrcFormatted;
  final String phone;

  const OtpScreen({
    super.key,
    required this.nrcFormatted,
    required this.phone,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the OTP code.'),
          backgroundColor: CustomerTheme.accentCrimson,
        ),
      );
      return;
    }

    context.read<CustomerAuthBloc>().add(
          VerifyOtpRequested(
            nrcFormatted: widget.nrcFormatted,
            phone: widget.phone,
            otpCode: code,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is AuthNeedsPinSetupState) {
            context.go(AppRouter.setPinRoute);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: CustomerTheme.accentCrimson),
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
                const Text(
                  'Enter 6-Digit SMS Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a verification code to ${widget.phone}.\nEnter the code below to verify your identity.',
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
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Verify Code (အတည်ပြုရန်)'),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: _resendCountdown == 0
                        ? () {
                            context.read<CustomerAuthBloc>().add(
                                  RequestOtpRequested(
                                    nrcFormatted: widget.nrcFormatted,
                                    phone: widget.phone,
                                  ),
                                );
                            _startTimer();
                          }
                        : null,
                    child: Text(
                      _resendCountdown > 0 ? 'Resend code in ${_resendCountdown}s' : 'Resend SMS Code (ကုတ်အသစ်ပြန်ပို့ရန်)',
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
