import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/bloc/language/language_cubit.dart';
import 'core/database/app_database.dart';
import 'core/network/api_client.dart';
import 'core/security/biometric_service.dart';
import 'core/security/secure_storage_service.dart';
import 'core/security/sqlcipher_key_manager.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/centers/data/repositories/center_repository_impl.dart';
import 'features/centers/presentation/bloc/center_bloc.dart';
import 'features/collection/data/repositories/collection_repository_impl.dart';
import 'features/collection/presentation/bloc/collection_bloc.dart';
import 'features/cash/data/services/cash_management_service_impl.dart';
import 'features/cash/presentation/bloc/cash_bloc.dart';
import 'features/insurance/data/repositories/insurance_claim_repository_impl.dart';
import 'features/insurance/presentation/bloc/insurance_claim_bloc.dart';
import 'features/origination/data/repositories/loan_origination_repository_impl.dart';
import 'features/origination/presentation/bloc/origination_bloc.dart';
import 'features/printer/data/services/bluetooth_printer_service_impl.dart';
import 'features/printer/presentation/bloc/printer_bloc.dart';
import 'features/savings/data/repositories/saving_repository_impl.dart';
import 'features/savings/presentation/bloc/saving_bloc.dart';
import 'features/sync/data/services/pull_sync_service_impl.dart';
import 'features/sync/data/services/push_batch_sync_service_impl.dart';
import 'features/sync/data/services/sync_engine_impl.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Initializing BMF Agent Mobile Application v1.0.0', tag: 'Bootstrap');

  // Initialize core secure services
  final secureStorage = SecureStorageService();
  final keyManager = SqlCipherKeyManager(secureStorage);
  final database = AppDatabase(keyManager);
  final apiClient = ApiClient(secureStorage: secureStorage);
  final biometricService = BiometricService();

  // Initialize BLoCs & Cubits
  final languageCubit = LanguageCubit(secureStorage);
  final authRepository = AuthRepositoryImpl(apiClient: apiClient, secureStorage: secureStorage);
  final authBloc = AuthBloc(authRepository: authRepository, biometricService: biometricService);

  final centerRepository = CenterRepositoryImpl(apiClient: apiClient, db: database);
  final centerBloc = CenterBloc(centerRepository: centerRepository);

  final collectionRepository = CollectionRepositoryImpl(apiClient: apiClient, db: database);
  final collectionBloc = CollectionBloc(collectionRepository: collectionRepository);

  // Initialize Bluetooth Printer Service & BLoC
  final printerService = BluetoothPrinterServiceImpl();
  final printerBloc = PrinterBloc(printerService: printerService);

  // Initialize Offline Sync Engine & BLoC
  final pullSyncService = PullSyncServiceImpl(apiClient: apiClient, database: database);
  final pushBatchSyncService = PushBatchSyncServiceImpl(apiClient: apiClient, database: database);
  final syncEngine = SyncEngineImpl(
    pullSyncService: pullSyncService,
    pushBatchSyncService: pushBatchSyncService,
    database: database,
  );
  syncEngine.start(); // Start background connectivity listener
  final syncBloc = SyncBloc(syncEngine: syncEngine);

  // Initialize Loan Origination Repository & BLoC
  final originationRepository = LoanOriginationRepositoryImpl(apiClient: apiClient, database: database);
  final originationBloc = OriginationBloc(originationRepository: originationRepository);

  // Initialize Village Savings Repository & BLoC
  final savingRepository = SavingRepositoryImpl(apiClient: apiClient, database: database);
  final savingBloc = SavingBloc(savingRepository: savingRepository);

  // Initialize Mutual Insurance Claim Repository & BLoC
  final claimRepository = InsuranceClaimRepositoryImpl(apiClient: apiClient, database: database);
  final claimBloc = InsuranceClaimBloc(claimRepository: claimRepository);

  // Initialize Physical Cash Management Service & BLoC
  final cashService = CashManagementServiceImpl(database: database);
  final cashBloc = CashBloc(cashService: cashService);

  runApp(
    BmfAgentApp(
      languageCubit: languageCubit,
      authBloc: authBloc,
      centerBloc: centerBloc,
      collectionBloc: collectionBloc,
      printerBloc: printerBloc,
      syncBloc: syncBloc,
      originationBloc: originationBloc,
      savingBloc: savingBloc,
      insuranceClaimBloc: claimBloc,
      cashBloc: cashBloc,
      printerService: printerService,
    ),
  );
}
