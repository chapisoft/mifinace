import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// Màn hình Splash khởi động ứng dụng: Tải cấu hình, kiểm tra phiên bảo mật và chuyển hướng phù hợp.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _checkAppSession();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAppSession() async {
    // Chờ hiệu ứng splash tối thiểu 1.2s để người dùng cảm nhận thương hiệu mượt mà
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    try {
      final storage = SecureStorageService();
      final token = await storage.getAuthToken();
      final lastIdentifier = await storage.getLastIdentifier();
      final lastFullName = await storage.getLastFullName();

      AppLogger.info('Splash session check: hasToken=${token != null}, lastIdentifier=$lastIdentifier', tag: 'SplashScreen');

      if (token != null && token.isNotEmpty) {
        if (!mounted) return;
        final authState = context.read<CustomerAuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.go(AppRouter.homeRoute);
          return;
        }
      }

      if (!mounted) return;

      if (lastIdentifier != null && lastIdentifier.isNotEmpty) {
        context.go(
          AppRouter.loginPinRoute,
          extra: {
            'identifier': lastIdentifier,
            'fullName': lastFullName ?? '',
          },
        );
        return;
      }

      context.go(AppRouter.loginIdentifierRoute);
    } catch (e, stack) {
      AppLogger.error('Failed to initialize splash session: $e', tag: 'SplashScreen', stackTrace: stack);
      if (mounted) {
        context.go(AppRouter.loginIdentifierRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: CustomerTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo Shield Box
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance,
                        size: 52,
                        color: CustomerTheme.primaryNavy,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Brand Titles
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'BMF Microfinance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.splashTagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Loading Spinner
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(CustomerTheme.secondaryAmber),
                ),
              ),

              const SizedBox(height: 28),

              // Footer Security Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: CustomerTheme.secondaryAmber),
                  const SizedBox(width: 6),
                  Text(
                    'FRD Myanmar Licensed MFI Platform',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withAlpha(180),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
