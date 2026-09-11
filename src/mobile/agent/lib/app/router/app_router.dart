import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/cash/presentation/screens/cash_screen.dart';
import '../../features/centers/presentation/screens/centers_screen.dart';
import '../../features/collection/presentation/screens/collection_sheet_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/insurance/presentation/screens/agent_claim_screen.dart';
import '../../features/origination/presentation/screens/loan_application_screen.dart';
import '../../features/printer/presentation/screens/printer_settings_screen.dart';
import '../../features/savings/presentation/screens/agent_saving_screen.dart';
import '../../features/savings/presentation/screens/open_saving_screen.dart';
import '../../features/sync/presentation/screens/sync_screen.dart';

/// Central GoRouter Navigation configuration for BMF Agent App.
class AppRouter {
  AppRouter._();

  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String centersRoute = '/centers';
  static const String collectionRoute = '/collection';
  static const String syncRoute = '/sync';
  static const String printerRoute = '/printer';
  static const String loanApplyRoute = '/loan-apply';
  static const String savingsRoute = '/savings';
  static const String openSavingRoute = '/savings/open';
  static const String claimRoute = '/claims';
  static const String cashRoute = '/cash';
  static const String settingsRoute = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: loginRoute,
    routes: [
      GoRoute(
        path: loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: dashboardRoute,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: centersRoute,
        name: 'centers',
        builder: (context, state) => const CentersScreen(),
      ),
      GoRoute(
        path: collectionRoute,
        name: 'collection',
        builder: (context, state) {
          final centerCode = state.uri.queryParameters['centerCode'] ?? 'C001';
          final centerName = state.uri.queryParameters['centerName'] ?? 'Taunggyi Central Center';
          final groupCode = state.uri.queryParameters['groupCode'] ?? 'G001';
          return CollectionSheetScreen(
            centerCode: centerCode,
            centerName: centerName,
            groupCode: groupCode,
          );
        },
      ),
      GoRoute(
        path: syncRoute,
        name: 'sync',
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: printerRoute,
        name: 'printer',
        builder: (context, state) => const PrinterSettingsScreen(),
      ),
      GoRoute(
        path: loanApplyRoute,
        name: 'loanApply',
        builder: (context, state) {
          final centerCode = state.uri.queryParameters['centerCode'] ?? 'C001';
          final groupCode = state.uri.queryParameters['groupCode'] ?? 'G001';
          return LoanApplicationScreen(
            centerCode: centerCode,
            groupCode: groupCode,
          );
        },
      ),
      GoRoute(
        path: savingsRoute,
        name: 'savings',
        builder: (context, state) {
          final centerCode = state.uri.queryParameters['centerCode'];
          return AgentSavingScreen(initialCenterCode: centerCode);
        },
      ),
      GoRoute(
        path: openSavingRoute,
        name: 'openSaving',
        builder: (context, state) {
          final centerCode = state.uri.queryParameters['centerCode'] ?? 'C001';
          final groupCode = state.uri.queryParameters['groupCode'] ?? 'G001';
          return OpenSavingScreen(centerCode: centerCode, groupCode: groupCode);
        },
      ),
      GoRoute(
        path: claimRoute,
        name: 'claim',
        builder: (context, state) {
          final centerCode = state.uri.queryParameters['centerCode'] ?? 'C001';
          final groupCode = state.uri.queryParameters['groupCode'] ?? 'G001';
          return AgentClaimScreen(centerCode: centerCode, groupCode: groupCode);
        },
      ),
      GoRoute(
        path: cashRoute,
        name: 'cash',
        builder: (context, state) => const CashScreen(),
      ),
    ],
  );
}
