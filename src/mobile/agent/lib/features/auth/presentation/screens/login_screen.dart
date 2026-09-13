import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../core/bloc/language/language_state.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/app_logger.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Modern Executive Screen for Agent Login - Optimized for Single Screen Display.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(AppLocalizations.of(context).loginValidationEmpty)),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    AppLogger.info('Agent login requested for user: $username', tag: 'LoginScreen');
    context.read<AuthBloc>().add(
          LoginRequested(
            username: username,
            password: password,
            deviceId: 'DEV-AGENT-01',
          ),
        );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectLanguageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = lang == currentLang;
            return ListTile(
              title: Text(
                '${lang.displayName} (${lang.nativeName})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.accentEmerald : AppTheme.textPrimary,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.accentEmerald) : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(lang);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 14,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_rounded, color: AppTheme.accentEmerald, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.appTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return TextButton.icon(
                onPressed: () => _showLanguageDialog(context),
                icon: const Icon(Icons.language, color: Colors.white, size: 16),
                label: Text(
                  langState.currentLanguage.code.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRouter.dashboardRoute);
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Curved Executive Hero Banner (Compact)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.accentEmerald.withAlpha(120), width: 1.5),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: AppTheme.accentEmerald, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.loginSubtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Card (Compact Single Screen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.agentAuthHeader,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.agentAuthDesc,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 14),

                            // Username Input
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: l10n.usernameLabel,
                                hintText: 'e.g. 2163896',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primarySlate, size: 20),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () => _usernameController.clear(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Password Input
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primarySlate, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppTheme.textSecondary,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In Button
                            ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 46),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.login, size: 17),
                                        const SizedBox(width: 6),
                                        Text(
                                          l10n.loginButton,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 10),

                            // Biometric Button
                            OutlinedButton.icon(
                              onPressed: () {
                                context.read<AuthBloc>().add(const BiometricLoginRequested());
                              },
                              icon: const Icon(Icons.fingerprint, color: AppTheme.accentEmerald, size: 20),
                              label: Text(l10n.biometricLogin, style: const TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryNavy,
                                side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Security Badge Footer
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: AppTheme.accentEmerald),
                        const SizedBox(width: 5),
                        Text(
                          l10n.securityBadgeFooter,
                          style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary.withAlpha(180)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
