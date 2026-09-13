import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bmf_agent_app/core/bloc/language/language_cubit.dart';
import 'package:bmf_agent_app/core/enums/user_role.dart';
import 'package:bmf_agent_app/core/l10n/app_localizations.dart';
import 'package:bmf_agent_app/core/security/secure_storage_service.dart';
import 'package:bmf_agent_app/features/auth/domain/entities/officer_profile.dart';
import 'package:bmf_agent_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_agent_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_agent_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bmf_agent_app/features/dashboard/presentation/screens/agent_navigation_screen.dart';
import 'package:bmf_agent_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bmf_agent_app/features/dashboard/presentation/screens/officer_account_screen.dart';
import 'package:bmf_agent_app/features/dashboard/presentation/widgets/agent_drawer.dart';
import 'package:bmf_agent_app/features/dashboard/presentation/widgets/agent_quick_actions_row.dart';
import 'package:bmf_agent_app/features/centers/domain/entities/center_item.dart';
import 'package:bmf_agent_app/features/centers/domain/entities/group_item.dart';
import 'package:bmf_agent_app/features/centers/domain/repositories/center_repository.dart';
import 'package:bmf_agent_app/features/centers/presentation/bloc/center_bloc.dart';
import 'package:bmf_agent_app/features/origination/domain/models/loan_application.dart';
import 'package:bmf_agent_app/features/origination/domain/repositories/loan_origination_repository.dart';
import 'package:bmf_agent_app/features/origination/presentation/bloc/origination_bloc.dart';
import 'package:bmf_agent_app/features/printer/domain/models/bluetooth_printer_device.dart';
import 'package:bmf_agent_app/features/printer/domain/services/bluetooth_printer_service.dart';
import 'package:bmf_agent_app/features/savings/domain/models/saving_account.dart';
import 'package:bmf_agent_app/features/savings/domain/models/saving_deposit.dart';
import 'package:bmf_agent_app/features/savings/domain/repositories/saving_repository.dart';
import 'package:bmf_agent_app/features/savings/presentation/bloc/saving_bloc.dart';

class _FakeSavingRepo implements SavingRepository {
  @override
  Future<List<SavingAccount>> getSavingAccounts({String? centerCode, String? query}) async => [];
  @override
  Future<SavingDeposit> depositSaving(SavingDeposit deposit) async => deposit;
  @override
  Future<SavingAccount> openSavingAccount(SavingAccount account, {double initialDepositMmk = 0.0}) async => account;
}

class _FakeCenterRepo implements CenterRepository {
  @override
  Future<List<CenterItem>> getCenters({bool forceRefresh = false}) async => [];
  @override
  Future<List<GroupItem>> getGroupsByCenter(String centerCode, {bool forceRefresh = false}) async => [];
}

class _FakeOriginationRepo implements LoanOriginationRepository {
  @override
  Future<LoanApplication> submitLoanApplication(LoanApplication application) async => application;
  @override
  Future<List<LoanApplication>> getPendingApplications() async => [];
}

class _FakePrinterService implements BluetoothPrinterService {
  @override
  Future<List<BluetoothPrinterDevice>> scanDevices() async => [];
  @override
  Future<bool> connect(BluetoothPrinterDevice device) async => true;
  @override
  Future<void> disconnect() async {}
  @override
  Future<bool> sendBytes(Uint8List bytes) async => true;
  @override
  bool get isConnected => false;
  @override
  BluetoothPrinterDevice? get connectedDevice => null;
}
class _MockAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _MockAuthBloc(super.initialState);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Agent App Modern Navigation & Dashboard Tests', () {
    late SecureStorageService secureStorage;
    late LanguageCubit languageCubit;
    late SavingBloc savingBloc;
    late CenterBloc centerBloc;
    late OriginationBloc originationBloc;
    late BluetoothPrinterService printerService;
    late _MockAuthBloc authBloc;

    setUp(() {
      secureStorage = SecureStorageService();
      languageCubit = LanguageCubit(secureStorage);
      savingBloc = SavingBloc(savingRepository: _FakeSavingRepo());
      centerBloc = CenterBloc(centerRepository: _FakeCenterRepo());
      originationBloc = OriginationBloc(originationRepository: _FakeOriginationRepo());
      printerService = _FakePrinterService();
      authBloc = _MockAuthBloc(
        const AuthAuthenticated(
          OfficerProfile(
            userId: 'AG001',
            username: 'aung_kyaw',
            fullName: 'U Aung Kyaw',
            role: UserRole.agent,
            branchCode: 'B001',
            branchName: 'Chi nhánh Taunggyi',
            townshipCode: 'TGY',
          ),
        ),
      );
    });

    Widget createTestWidget(Widget child) {
      return RepositoryProvider<BluetoothPrinterService>.value(
        value: printerService,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<LanguageCubit>.value(value: languageCubit),
            BlocProvider<SavingBloc>.value(value: savingBloc),
            BlocProvider<CenterBloc>.value(value: centerBloc),
            BlocProvider<OriginationBloc>.value(value: originationBloc),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('vi'),
            home: child,
          ),
        ),
      );
    }

    testWidgets('DashboardScreen renders officer greeting, hero metrics and quick actions', (tester) async {
      await tester.pumpWidget(createTestWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('U Aung Kyaw'), findsOneWidget);
      expect(find.text('Thu nợ cụm'), findsOneWidget);
      expect(find.text('Vay mới KYC'), findsOneWidget);
      expect(find.text('Gửi tiết kiệm'), findsOneWidget);
      expect(find.text('Lịch cụm GD'), findsOneWidget);
      expect(find.text('Lịch họp cụm hôm nay'), findsOneWidget);
    });

    testWidgets('AgentDrawer renders all 8 operation modules and system options', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Scaffold(
            drawer: AgentDrawer(),
            body: Text('Test Drawer'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('U Aung Kyaw'), findsOneWidget);
      expect(find.text('TÁC NGHIỆP ĐẠI LÝ'), findsOneWidget);
      
      final listFinder = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(find.text('THIẾT BỊ & ĐỒNG BỘ'), 100.0, scrollable: listFinder);
      expect(find.text('THIẾT BỊ & ĐỒNG BỘ'), findsOneWidget);
    });

    testWidgets('OfficerAccountScreen renders profile, printer, sync and security cards', (tester) async {
      await tester.pumpWidget(createTestWidget(const OfficerAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('U Aung Kyaw'), findsOneWidget);
      expect(find.text('THIẾT BỊ NGOẠI VI & IN ẤN'), findsOneWidget);
      expect(find.text('DỮ LIỆU NGOẠI TUYẾN & ĐỒNG BỘ'), findsOneWidget);
      expect(find.text('BẢO MẬT & XÁC THỰC PHIÊN'), findsOneWidget);
    });

    testWidgets('AgentQuickActionsRow triggers callback on tap', (tester) async {
      bool collectionTapped = false;
      bool customizeTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          Scaffold(
            body: AgentQuickActionsRow(
              onCollection: () => collectionTapped = true,
              onNewLoan: () {},
              onSavings: () {},
              onCenters: () {},
              onCustomize: () => customizeTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Thu nợ cụm'));
      expect(collectionTapped, isTrue);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      expect(customizeTapped, isTrue);
    });

    testWidgets('AgentNavigationScreen renders bottom navigation bar and switches tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(const AgentNavigationScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Tài khoản'), findsOneWidget);

      // Tap on Account tab
      await tester.tap(find.text('Tài khoản'));
      await tester.pumpAndSettle();

      expect(find.text('THIẾT BỊ NGOẠI VI & IN ẤN'), findsOneWidget);
    });
  });
}
