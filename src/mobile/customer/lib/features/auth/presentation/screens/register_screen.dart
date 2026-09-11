import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/customer_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Screen allowing borrowers to register their mobile account using NRC and registered phone.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Zero fake default values: text controllers start empty
  final _nrcController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nrcController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CustomerAuthBloc>().add(
          RequestOtpRequested(
            nrcFormatted: _nrcController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Registration'),
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is AuthOtpSentState) {
            context.push(
              '${AppRouter.otpRoute}?nrc=${Uri.encodeComponent(state.nrcFormatted)}&phone=${Uri.encodeComponent(state.phone)}',
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: CustomerTheme.accentCrimson),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: CustomerTheme.primaryNavy.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_outlined, size: 36, color: CustomerTheme.primaryNavy),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Register Your BMF Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the NRC number and mobile number registered in your BMF loan agreement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                // NRC Input
                TextFormField(
                  controller: _nrcController,
                  decoration: const InputDecoration(
                    labelText: 'Myanmar NRC Card *',
                    hintText: 'e.g. 12/DAGANA(N)123456',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'NRC Card is required' : null,
                ),
                const SizedBox(height: 16),

                // Phone Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Phone Number *',
                    hintText: 'e.g. 09123456789',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.sms_outlined),
                  label: Text(isLoading ? 'Sending SMS OTP...' : 'Send SMS OTP (SMS ပို့ရန်)'),
                  onPressed: isLoading ? null : _submit,
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => context.go(AppRouter.loginPinRoute),
                  child: const Text('Already registered? Log in with PIN'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
