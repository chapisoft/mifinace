import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/customer_theme.dart';
import '../../../../core/l10n/customer_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Màn hình kích hoạt tài khoản ứng dụng di động cho thành viên BMF.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final identifier = _identifierController.text.trim();
    context.read<CustomerAuthBloc>().add(
          SendActivationOtpRequested(identifier: identifier),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.activateNow, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) {
          if (state is AuthActivationOtpSentState) {
            context.push(
              AppRouter.otpRoute,
              extra: {
                'identifier': state.identifier,
                'maskedPhone': state.maskedPhone,
                'purpose': 'ACTIVATION',
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
                      color: CustomerTheme.primaryCyan.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_outlined, size: 36, color: CustomerTheme.primaryCyan),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.activateNow,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.activateWithInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: CustomerTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                // Identifier Input
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: l10n.memberIdOrPhoneOrNrc,
                    hintText: '2150002 / 09448034049 / NRC',
                    prefixIcon: const Icon(Icons.badge_outlined, color: CustomerTheme.primaryCyan),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? l10n.inputIdentifierRequired
                      : null,
                ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.sms_outlined),
                  label: Text(l10n.requestOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.primaryCyan,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isLoading ? null : _submit,
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => context.go(AppRouter.loginPinRoute),
                  child: Text(
                    l10n.loginTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: CustomerTheme.primaryCyan),
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
