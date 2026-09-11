import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/saving_product_type.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/saving_account.dart';
import '../../domain/models/saving_deposit.dart';
import '../../domain/repositories/saving_repository.dart';

/// Implementation of [SavingRepository] supporting offline-first SQLite queueing and remote sync.
class SavingRepositoryImpl implements SavingRepository {
  final ApiClient _apiClient;
  final AppDatabase _database;
  final Uuid _uuid;

  // In-memory local cache of village savings accounts synchronized during pull sync
  final List<SavingAccount> _cachedAccounts = [];

  SavingRepositoryImpl({
    required ApiClient apiClient,
    required AppDatabase database,
    Uuid? uuid,
  })  : _apiClient = apiClient,
        _database = database,
        _uuid = uuid ?? const Uuid() {
    _initDemoVillageAccounts();
  }

  void _initDemoVillageAccounts() {
    // Initial catalog of village center savings accounts (retrieved during daily pull sync)
    _cachedAccounts.addAll([
      SavingAccount(
        accountId: 'SA001',
        accountNumber: 'SAV-2026-00891',
        centerCode: 'C001',
        groupCode: 'G001',
        customerName: 'Daw Khin Khin Win',
        nrcFormatted: '12/DAGANA(N)123456',
        phone: '09123456789',
        productType: SavingProductType.compulsory,
        balanceMmk: 250000.0,
        interestRateAnnual: 10.0,
        openedDate: DateTime(2025, 6, 1),
        nomineeName: 'U Mg Mg',
        nomineeNrc: '12/DAGANA(N)654321',
        nomineeRelation: 'Spouse',
      ),
      SavingAccount(
        accountId: 'SA002',
        accountNumber: 'SAV-2026-00892',
        centerCode: 'C001',
        groupCode: 'G001',
        customerName: 'Daw Nilar Myint',
        nrcFormatted: '12/DAGANA(N)234567',
        phone: '09234567890',
        productType: SavingProductType.voluntary,
        balanceMmk: 480000.0,
        interestRateAnnual: 12.0,
        openedDate: DateTime(2025, 8, 15),
        nomineeName: 'Ko Aung Kyaw',
        nomineeNrc: '12/DAGANA(N)765432',
        nomineeRelation: 'Son',
      ),
      SavingAccount(
        accountId: 'SA003',
        accountNumber: 'SAV-2026-00910',
        centerCode: 'C002',
        groupCode: 'G003',
        customerName: 'Daw Hla Hla Than',
        nrcFormatted: '9/MAHAMA(N)345678',
        phone: '09345678901',
        productType: SavingProductType.fixedTerm,
        balanceMmk: 1000000.0,
        interestRateAnnual: 14.0,
        openedDate: DateTime(2025, 1, 10),
        nomineeName: 'Daw San San',
        nomineeNrc: '9/MAHAMA(N)876543',
        nomineeRelation: 'Mother',
      ),
    ]);
  }

  @override
  Future<List<SavingAccount>> getSavingAccounts({String? centerCode, String? query}) async {
    AppLogger.debug('Fetching savings accounts (center: $centerCode, query: $query)', tag: 'SavingRepo');
    var result = List<SavingAccount>.from(_cachedAccounts);

    if (centerCode != null && centerCode.isNotEmpty) {
      result = result.where((acc) => acc.centerCode.toUpperCase() == centerCode.toUpperCase()).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((acc) {
        return acc.customerName.toLowerCase().contains(q) ||
            acc.accountNumber.toLowerCase().contains(q) ||
            acc.nrcFormatted.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  @override
  Future<SavingDeposit> depositSaving(SavingDeposit deposit) async {
    AppLogger.info(
      'Processing savings deposit: ${deposit.amountMmk} MMK for Account ${deposit.accountNumber}',
      tag: 'SavingRepo',
    );

    // 1. Update local cached account balance immediately
    final index = _cachedAccounts.indexWhere((acc) => acc.accountNumber == deposit.accountNumber);
    double newBalance = deposit.amountMmk;
    if (index != -1) {
      final oldAcc = _cachedAccounts[index];
      newBalance = oldAcc.balanceMmk + deposit.amountMmk;
      _cachedAccounts[index] = oldAcc.copyWith(balanceMmk: newBalance);
    }

    final updatedDeposit = SavingDeposit(
      depositId: deposit.depositId,
      accountNumber: deposit.accountNumber,
      customerName: deposit.customerName,
      amountMmk: deposit.amountMmk,
      newBalanceMmk: newBalance,
      depositDate: deposit.depositDate,
      officerId: deposit.officerId,
      idempotencyKey: deposit.idempotencyKey,
      syncStatus: SyncStatus.pending,
    );

    // 2. Enqueue into SQLite local_sync_queue with Idempotency Key
    final queueId = _uuid.v4();
    final payloadJson = jsonEncode(updatedDeposit.toJson());

    await _database.enqueueSyncOperation(
      LocalSyncQueueTableCompanion(
        queueId: Value(queueId),
        operationType: const Value('SAVING_DEPOSIT'),
        entityId: Value(deposit.depositId),
        payloadJson: Value(payloadJson),
        idempotencyKey: Value(deposit.idempotencyKey),
        status: const Value('PENDING'),
        createdAt: Value(DateTime.now()),
      ),
    );

    // 3. Attempt immediate online upload if network available
    try {
      final response = await _apiClient.post(
        '/api/v1/mobile/savings/deposit',
        data: updatedDeposit.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _database.updateSyncQueueStatus(queueId, SyncStatus.completed);
        AppLogger.info('Savings deposit synced to core immediately: ${deposit.depositId}', tag: 'SavingRepo');
      }
    } catch (e) {
      AppLogger.warn('Immediate Gateway upload failed. Deposit queued offline: $e', tag: 'SavingRepo');
    }

    return updatedDeposit;
  }

  @override
  Future<SavingAccount> openSavingAccount(SavingAccount account, {double initialDepositMmk = 0.0}) async {
    AppLogger.info('Opening new field savings account: ${account.accountNumber} for ${account.customerName}', tag: 'SavingRepo');

    final updatedAccount = account.copyWith(balanceMmk: initialDepositMmk);
    _cachedAccounts.add(updatedAccount);

    // Enqueue account creation
    final queueId = _uuid.v4();
    final idempotencyKey = _uuid.v4();
    final payloadJson = jsonEncode({
      'account': updatedAccount.toJson(),
      'initialDepositMmk': initialDepositMmk,
    });

    await _database.enqueueSyncOperation(
      LocalSyncQueueTableCompanion(
        queueId: Value(queueId),
        operationType: const Value('SAVING_OPEN'),
        entityId: Value(updatedAccount.accountId),
        payloadJson: Value(payloadJson),
        idempotencyKey: Value(idempotencyKey),
        status: const Value('PENDING'),
        createdAt: Value(DateTime.now()),
      ),
    );

    return updatedAccount;
  }
}
