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
import '../widgets/random_numeric_keypad.dart';

/// Màn hình Bước 2 Đăng nhập: Nhập mã PIN 6 số bảo mật với bàn phím ngẫu nhiên và sinh trắc học.
class LoginPinScreen extends StatefulWidget {
  final String? identifier;
  final String? fullName;
  final String? nrcFormatted;

  const LoginPinScreen({
    super.key,
    this.identifier,
    this.fullName,
    this.nrcFormatted,
  });

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  String _enteredPin = '';
  String _activeIdentifier = '';
  String _activeFullName = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activeIdentifier = widget.identifier ?? '';
    _activeFullName = widget.fullName ?? '';
    _loadSavedAccountIfNeeded();
  }

  Future<void> _loadSavedAccountIfNeeded() async {
    if (_activeIdentifier.isEmpty) {
      final savedId = await SecureStorageService().getLastIdentifier();
      final savedName = await SecureStorageService().getLastFullName();
      if (savedId != null && savedId.isNotEmpty && mounted) {
        setState(() {
          _activeIdentifier = savedId;
          _activeFullName = savedName ?? '';
        });
      } else if (mounted) {
        context.go(AppRouter.loginIdentifierRoute);
      }
    }
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

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 6) {
      setState(() {
        _errorMessage = null;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 6) {
        _submitPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _submitPin() {
    if (_activeIdentifier.isEmpty) {
      context.go(AppRouter.loginIdentifierRoute);
      return;
    }

    context.read<CustomerAuthBloc>().add(
          LoginWithNrcAndPinRequested(
            nrc: _activeIdentifier,
            pin: _enteredPin,
          ),
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
          if (state is AuthAuthenticated) {
            await SecureStorageService().saveLastIdentifier(_activeIdentifier);
            if (state.profile.fullName.isNotEmpty) {
              await SecureStorageService().saveLastFullName(state.profile.fullName);
            }
            if (context.mounted) {
              context.go(AppRouter.homeRoute);
            }
          } else if (state is AuthError) {
            final cleanMsg = state.errorMessage.replaceAll('Exception: ', '').trim();
            setState(() {
              _enteredPin = '';
              _errorMessage = cleanMsg;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Active Member Identity Header Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: CustomerTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: CustomerTheme.primaryCyan.withAlpha(25),
                          child: const Icon(Icons.person, color: CustomerTheme.primaryCyan, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeFullName.isNotEmpty ? _activeFullName : l10n.savedMemberAccount,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: CustomerTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.memberCode}: $_activeIdentifier',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => context.push(AppRouter.loginIdentifierRoute),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: CustomerTheme.primaryNavy.withAlpha(12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CustomerTheme.primaryNavy.withAlpha(40)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.swap_horiz, size: 14, color: CustomerTheme.primaryNavy),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.switchAccount,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: CustomerTheme.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Enter 6-digit PIN instruction
                  Text(
                    l10n.enter6DigitPin,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: CustomerTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Error Message Box
                  if (_errorMessage != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: CustomerTheme.accentCrimson.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CustomerTheme.accentCrimson.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: CustomerTheme.accentCrimson, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: CustomerTheme.accentCrimson, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 6 PIN Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      final isFilled = i < _enteredPin.length;
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

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(color: CustomerTheme.primaryCyan),
                    )
                  else ...[
                    // Randomized Keypad
                    RandomNumericKeypad(
                      onKeyPressed: _onDigitPressed,
                      onDeletePressed: _onDeletePressed,
                      showBiometric: true,
                      onBiometricPressed: () {
                        context.read<CustomerAuthBloc>().add(const LoginWithBiometricRequested());
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot PIN Button
                    TextButton(
                      onPressed: () {
                        if (_activeIdentifier.isNotEmpty) {
                          context.read<CustomerAuthBloc>().add(
                                SendForgotPinOtpRequested(identifier: _activeIdentifier),
                              );
                          context.push(
                            AppRouter.otpRoute,
                            extra: {
                              'identifier': _activeIdentifier,
                              'maskedPhone': '',
                              'purpose': 'RESET_PIN',
                            },
                          );
                        }
                      },
                      child: Text(
                        l10n.forgotPin,
                        style: const TextStyle(
                          color: CustomerTheme.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
