import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/bloc/language/language_cubit.dart';
import 'package:bmf_customer/core/bloc/language/language_state.dart';
import 'package:bmf_customer/core/enums/app_language.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Màn hình Bước 1 Đăng nhập: Nhập Mã thành viên, Số điện thoại hoặc Thẻ NRC.
class LoginIdentifierScreen extends StatefulWidget {
  const LoginIdentifierScreen({super.key});

  @override
  State<LoginIdentifierScreen> createState() => _LoginIdentifierScreenState();
}

class _LoginIdentifierScreenState extends State<LoginIdentifierScreen> {
  final _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedIdentifier();
  }

  Future<void> _loadSavedIdentifier() async {
    final saved = await SecureStorageService().getLastIdentifier();
    if (saved != null && saved.isNotEmpty && mounted) {
      _identifierController.text = saved;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);
    final currentLang = context.read<LanguageCubit>().state.currentLanguage;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.selectLanguage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = lang == currentLang;
            return ListTile(
              title: Text(
                '${lang.displayName} (${lang.nativeName})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? CustomerTheme.primaryCyan : CustomerTheme.textPrimary,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: CustomerTheme.primaryCyan) : null,
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

  void _promptActivationDialog(BuildContext context, String identifier) {
    final l10n = CustomerLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: CustomerTheme.primaryCyan, size: 22),
            const SizedBox(width: 8),
            Text(l10n.setPinTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          l10n.notActivatedPrompt,
          style: const TextStyle(fontSize: 13, color: CustomerTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: const TextStyle(color: CustomerTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<CustomerAuthBloc>().add(
                    SendActivationOtpRequested(identifier: identifier),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomerTheme.primaryCyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.activateNow),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    setState(() => _errorMessage = null);
    final input = _identifierController.text.trim();
    if (input.isEmpty) {
      final l10n = CustomerLocalizations.of(context);
      setState(() => _errorMessage = l10n.inputIdentifierRequired);
      return;
    }

    context.read<CustomerAuthBloc>().add(
          CheckAccountRequested(identifier: input, userType: 'CUSTOMER'),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, color: CustomerTheme.secondaryAmber, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return TextButton.icon(
                onPressed: () => _showLanguageDialog(context),
                icon: const Icon(Icons.language, color: Colors.white, size: 18),
                label: Text(
                  langState.currentLanguage.code.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
        listener: (context, state) async {
          if (state is AuthAccountCheckedState) {
            final result = state.account;
            if (result.isNotActivated) {
              _promptActivationDialog(context, result.identifier);
            } else if (result.isActivated) {
              await SecureStorageService().saveLastIdentifier(result.businessId.isNotEmpty ? result.businessId : result.identifier);
              if (result.fullName.isNotEmpty) {
                await SecureStorageService().saveLastFullName(result.fullName);
              }
              if (context.mounted) {
                context.push(
                  AppRouter.loginPinRoute,
                  extra: {
                    'identifier': result.businessId.isNotEmpty ? result.businessId : result.identifier,
                    'fullName': result.fullName,
                    'nrcFormatted': result.nrcFormatted,
                  },
                );
              }
            }
          } else if (state is AuthActivationOtpSentState) {
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
            setState(() => _errorMessage = cleanMsg);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Hero Brand Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: const BoxDecoration(
                      gradient: CustomerTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
                          ),
                          child: const Icon(Icons.account_balance, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.loginTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.splashTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 1 Form Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: CustomerTheme.borderSubtle),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.loginTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CustomerTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.memberIdOrPhoneOrNrc,
                                style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                              ),
                              const SizedBox(height: 18),

                              // Error Banner if present
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: CustomerTheme.accentCrimson.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: CustomerTheme.accentCrimson.withAlpha(80)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: CustomerTheme.accentCrimson, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: CustomerTheme.accentCrimson, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Identifier Input Field
                              TextFormField(
                                controller: _identifierController,
                                decoration: InputDecoration(
                                  labelText: l10n.memberIdOrPhoneOrNrc,
                                  hintText: '2150001 / 09420076759 / NRC',
                                  prefixIcon: const Icon(Icons.person_outline, color: CustomerTheme.primaryCyan),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => _identifierController.clear(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Continue Button
                              ElevatedButton(
                                onPressed: isLoading ? null : _handleContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomerTheme.primaryCyan,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.continueButton,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward, size: 18),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Activation Action Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: CustomerTheme.borderSubtle),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CustomerTheme.primaryCyan.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_user_outlined, color: CustomerTheme.primaryCyan, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.firstTimeUsingApp, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text(l10n.activateWithInfo, style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary)),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () {
                                final input = _identifierController.text.trim();
                                if (input.isNotEmpty) {
                                  context.read<CustomerAuthBloc>().add(SendActivationOtpRequested(identifier: input));
                                } else {
                                  context.push(AppRouter.registerRoute);
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(l10n.activateNow, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
