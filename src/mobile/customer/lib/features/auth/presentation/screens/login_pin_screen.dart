import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/customer_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/random_numeric_keypad.dart';

/// Daily Login Screen with 6-digit PIN and Biometric Authentication.
class LoginPinScreen extends StatefulWidget {
  const LoginPinScreen({super.key});

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  String _enteredPin = '';

  @override
  void initState() {
    super.initState();
    // Attempt fast biometric unlock if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerAuthBloc>().add(const LoginWithBiometricRequested());
    });
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 6) {
      setState(() => _enteredPin += digit);
      if (_enteredPin.length == 6) {
        context.read<CustomerAuthBloc>().add(LoginWithPinRequested(pin: _enteredPin));
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go(AppRouter.homeRoute);
            } else if (state is AuthError) {
              setState(() => _enteredPin = '');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage), backgroundColor: CustomerTheme.accentCrimson),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 32),
                // Logo & Greeting
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: CustomerTheme.primaryNavy.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance, size: 36, color: CustomerTheme.primaryNavy),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BMF Microfinance Myanmar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your 6-digit PIN to access account',
                  style: TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
                ),
                const SizedBox(height: 28),

                // 6 PIN Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final isFilled = i < _enteredPin.length;
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

                const Spacer(),

                // Randomized Keypad
                RandomNumericKeypad(
                  onKeyPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  showBiometric: true,
                  onBiometricPressed: () {
                    context.read<CustomerAuthBloc>().add(const LoginWithBiometricRequested());
                  },
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.push(AppRouter.registerRoute),
                  child: const Text('New Borrower? Register Here'),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
