import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/bloc/language/language_cubit.dart';
import 'package:bmf_customer/core/bloc/language/language_state.dart';
import 'package:bmf_customer/core/enums/app_language.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/security/biometric_service.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import 'package:bmf_customer/features/auth/domain/repositories/customer_auth_repository.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_customer/features/loans/domain/repositories/customer_loan_repository.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/payments/domain/repositories/payment_repository.dart';
import 'package:bmf_customer/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:bmf_customer/features/savings/domain/repositories/savings_repository.dart';
import 'package:bmf_customer/features/savings/presentation/bloc/savings_bloc.dart';

/// Root application widget for BMF Customer Mobile App.
class BmfCustomerApp extends StatelessWidget {
  final SecureStorageService secureStorageService;
  final BiometricService biometricService;
  final CustomerAuthRepository authRepository;
  final CustomerLoanRepository loanRepository;
  final PaymentRepository paymentRepository;
  final SavingsRepository savingsRepository;

  const BmfCustomerApp({
    super.key,
    required this.secureStorageService,
    required this.biometricService,
    required this.authRepository,
    required this.loanRepository,
    required this.paymentRepository,
    required this.savingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SecureStorageService>.value(value: secureStorageService),
        RepositoryProvider<BiometricService>.value(value: biometricService),
        RepositoryProvider<CustomerAuthRepository>.value(value: authRepository),
        RepositoryProvider<CustomerLoanRepository>.value(value: loanRepository),
        RepositoryProvider<PaymentRepository>.value(value: paymentRepository),
        RepositoryProvider<SavingsRepository>.value(value: savingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LanguageCubit>(
            create: (_) => LanguageCubit(secureStorageService),
          ),
          BlocProvider<CustomerAuthBloc>(
            create: (_) => CustomerAuthBloc(
              authRepository: authRepository,
              storageService: secureStorageService,
            )..add(const CheckSessionRequested()),
          ),
          BlocProvider<CustomerLoanBloc>(
            create: (_) => CustomerLoanBloc(
              loanRepository: loanRepository,
            )..add(const LoadActiveLoansRequested('12/DAGAMA(N)045612')),
          ),
          BlocProvider<PaymentBloc>(
            create: (_) => PaymentBloc(
              paymentRepository: paymentRepository,
            ),
          ),
          BlocProvider<SavingsBloc>(
            create: (_) => SavingsBloc(
              savingsRepository: savingsRepository,
            ),
          ),
        ],
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            return MaterialApp.router(
              title: 'BMF Microfinance Customer',
              debugShowCheckedModeBanner: false,
              theme: CustomerTheme.lightTheme,
              themeMode: ThemeMode.light,
              locale: langState.currentLanguage.locale,
              supportedLocales: AppLanguage.values.map((l) => l.locale).toList(),
              localizationsDelegates: CustomerLocalizations.localizationsDelegates,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
