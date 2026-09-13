import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/customer_theme.dart';
import '../../../../core/l10n/customer_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/random_numeric_keypad.dart';

/// Màn hình thiết lập mã PIN 6 số với bàn phím số ngẫu nhiên chống nhìn trộm (anti-shoulder surfing).
class SetPinScreen extends StatefulWidget {
  final String token;
  final String purpose; // 'ACTIVATION' | 'RESET_PIN'

  const SetPinScreen({
    super.key,
    required this.token,
    this.purpose = 'ACTIVATION',
  });

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _enableBiometric = true;

  void _onDigitPressed(String digit) {
    if (!_isConfirming) {
      if (_pin.length < 6) {
        setState(() => _pin += digit);
        if (_pin.length == 6) {
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() => _isConfirming = true);
          });
        }
      }
    } else {
      if (_confirmPin.length < 6) {
        setState(() => _confirmPin += digit);
        if (_confirmPin.length == 6) {
          _verifyAndSubmit();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (!_isConfirming) {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      } else {
        setState(() {
          _isConfirming = false;
          _pin = '';
        });
      }
    }
  }

  void _verifyAndSubmit() {
    final l10n = CustomerLocalizations.of(context);
    if (_pin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinMismatch),
          backgroundColor: CustomerTheme.accentCrimson,
        ),
      );
      setState(() {
        _isConfirming = false;
        _pin = '';
        _confirmPin = '';
      });
      return;
    }

    if (widget.purpose == 'ACTIVATION') {
      context.read<CustomerAuthBloc>().add(
            ActivateAccountRequested(
              activationToken: widget.token,
              pinCode: _pin,
              enableBiometric: _enableBiometric,
            ),
          );
    } else {
      context.read<CustomerAuthBloc>().add(
            ResetPinRequested(
              resetPinToken: widget.token,
              newPinCode: _pin,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final currentInput = _isConfirming ? _confirmPin : _pin;
    final isActivation = widget.purpose == 'ACTIVATION';
    final headerTitle = _isConfirming ? l10n.confirmPinTitle : l10n.setPinTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(headerTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pinSuccess),
                backgroundColor: CustomerTheme.primaryCyan,
              ),
            );
            context.go(AppRouter.homeRoute);
          } else if (state is AuthError) {
            final cleanMsg = state.errorMessage.replaceAll('Exception: ', '').trim();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(cleanMsg),
                backgroundColor: CustomerTheme.accentCrimson,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              _isConfirming = false;
              _pin = '';
              _confirmPin = '';
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            children: [
              const SizedBox(height: 24),
              Text(
                _isConfirming ? l10n.confirmPinTitle : l10n.setPinTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.enter6DigitPin,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // 6 PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final isFilled = i < currentInput.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? CustomerTheme.primaryCyan : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? CustomerTheme.primaryCyan : CustomerTheme.borderSubtle,
                        width: 2.2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              if (!_isConfirming && isActivation)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.biometricLogin, style: const TextStyle(fontSize: 13)),
                    value: _enableBiometric,
                    activeColor: CustomerTheme.primaryCyan,
                    onChanged: (val) => setState(() => _enableBiometric = val ?? true),
                  ),
                ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: CustomerTheme.primaryCyan),
                ),

              const Spacer(),

              // Randomized Keypad
              RandomNumericKeypad(
                onKeyPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: false,
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
