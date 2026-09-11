import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/customer_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/random_numeric_keypad.dart';

/// Screen for creating a 6-digit security PIN with anti-shoulder surfing randomized keypad.
class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

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
    if (_pin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN numbers do not match. Please try again.'),
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

    context.read<CustomerAuthBloc>().add(
          SetupPinRequested(
            pin: _pin,
            enableBiometric: _enableBiometric,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentInput = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirming ? 'Confirm Security PIN' : 'Create 6-Digit PIN'),
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRouter.homeRoute);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: CustomerTheme.accentCrimson),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 24),
              Text(
                _isConfirming ? 'Re-enter your 6-digit PIN to confirm' : 'Set a memorable 6-digit security PIN',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              const Text(
                'Used for quick daily login and approving digital payments.',
                style: TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // 6 PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final isFilled = i < currentInput.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? CustomerTheme.primaryNavy : Colors.transparent,
                      border: Border.all(color: CustomerTheme.primaryNavy, width: 2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              if (!_isConfirming)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Fingerprint / Face Unlock', style: TextStyle(fontSize: 13)),
                    value: _enableBiometric,
                    activeColor: CustomerTheme.primaryNavy,
                    onChanged: (val) => setState(() => _enableBiometric = val ?? true),
                  ),
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
