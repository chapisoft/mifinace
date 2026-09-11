import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../core/bloc/language/language_state.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/utils/app_logger.dart';

/// Screen for Credit Officer Login and Device Verification.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter officer username and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    AppLogger.info('Officer login requested for user: $username', tag: 'LoginScreen');

    // Simulate login verification
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCubit = context.watch<LanguageCubit>();
    final currentLang = langCubit.state.currentLanguage;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('BMF Microfinance'),
        actions: [
          PopupMenuButton<AppLanguage>(
            icon: const Icon(Icons.language, color: Colors.white),
            initialValue: currentLang,
            onSelected: (AppLanguage newLang) {
              context.read<LanguageCubit>().changeLanguage(newLang);
            },
            itemBuilder: (context) => AppLanguage.values.map((lang) {
              return PopupMenuItem<AppLanguage>(
                value: lang,
                child: Text(
                  '${lang.displayName} (${lang.nativeName})',
                  style: TextStyle(
                    fontWeight: lang == currentLang ? FontWeight.bold : FontWeight.normal,
                    color: lang == currentLang ? AppTheme.primaryNavy : AppTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_balance,
                    size: 56,
                    color: AppTheme.primaryNavy,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'BMF Credit Officer Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Microfinance Field Operations Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Officer Username',
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryNavy),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryNavy),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Log In'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      AppLogger.info('Triggered biometric login', tag: 'LoginScreen');
                      context.go('/dashboard');
                    },
                    icon: const Icon(Icons.fingerprint, color: AppTheme.primaryNavy),
                    label: const Text('Log In with Biometrics'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
