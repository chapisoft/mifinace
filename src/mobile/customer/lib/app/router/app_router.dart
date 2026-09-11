import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_pin_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/set_pin_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/insurance/presentation/screens/claim_submission_screen.dart';
import '../../features/loans/domain/models/customer_loan.dart';
import '../../features/loans/presentation/screens/loan_list_screen.dart';
import '../../features/loans/presentation/screens/loan_schedule_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/payments/presentation/bloc/payment_state.dart';
import '../../features/payments/presentation/screens/payment_qr_screen.dart';
import '../../features/payments/presentation/screens/payment_success_screen.dart';
import '../../features/savings/presentation/screens/cust_open_saving_screen.dart';
import '../../features/savings/presentation/screens/savings_screen.dart';

/// App routing configuration using GoRouter.
class AppRouter {
  static const String loginPinRoute = '/login-pin';
  static const String registerRoute = '/register';
  static const String otpRoute = '/otp';
  static const String setPinRoute = '/set-pin';
  static const String homeRoute = '/home';
  static const String loansRoute = '/loans';
  static const String loanScheduleRoute = '/loans/schedule';
  static const String paymentQrRoute = '/payment/qr';
  static const String paymentSuccessRoute = '/payment/success';
  static const String savingsRoute = '/savings';
  static const String openSavingRoute = '/savings/open';
  static const String insuranceClaimRoute = '/insurance/claim';
  static const String notificationsRoute = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: loginPinRoute,
    routes: [
      GoRoute(
        path: loginPinRoute,
        builder: (context, state) => const LoginPinScreen(),
      ),
      GoRoute(
        path: registerRoute,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: otpRoute,
        builder: (context, state) {
          final nrc = state.uri.queryParameters['nrc'] ?? '';
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(nrcFormatted: nrc, phone: phone);
        },
      ),
      GoRoute(
        path: setPinRoute,
        builder: (context, state) => const SetPinScreen(),
      ),
      GoRoute(
        path: homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: loansRoute,
        builder: (context, state) {
          final memberNrc = state.extra as String? ?? '';
          return LoanListScreen(memberNrc: memberNrc);
        },
      ),
      GoRoute(
        path: loanScheduleRoute,
        builder: (context, state) {
          final loan = state.extra as CustomerLoan;
          return LoanScheduleScreen(loan: loan);
        },
      ),
      GoRoute(
        path: paymentQrRoute,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final contractCode = extra['contractCode'] as String? ?? '';
          final amountMmk = (extra['amountMmk'] as num?)?.toDouble() ?? 0.0;
          return PaymentQrScreen(contractCode: contractCode, amountMmk: amountMmk);
        },
      ),
      GoRoute(
        path: paymentSuccessRoute,
        builder: (context, state) {
          final paymentData = state.extra as PaymentSuccess;
          return PaymentSuccessScreen(paymentData: paymentData);
        },
      ),
      GoRoute(
        path: savingsRoute,
        builder: (context, state) {
          final memberNrc = state.extra as String? ?? '';
          return SavingsScreen(memberNrc: memberNrc);
        },
      ),
      GoRoute(
        path: openSavingRoute,
        builder: (context, state) {
          final memberNrc = state.extra as String? ?? '';
          return CustOpenSavingScreen(memberNrc: memberNrc);
        },
      ),
      GoRoute(
        path: insuranceClaimRoute,
        builder: (context, state) {
          final memberNrc = state.extra as String? ?? '';
          return ClaimSubmissionScreen(memberNrc: memberNrc);
        },
      ),
      GoRoute(
        path: notificationsRoute,
        builder: (context, state) => const NotificationCenterScreen(),
      ),
    ],
  );
}
