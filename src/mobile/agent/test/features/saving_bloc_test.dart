import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/saving_product_type.dart';
import 'package:bmf_agent_app/core/enums/sync_status.dart';
import 'package:bmf_agent_app/features/savings/domain/models/saving_account.dart';
import 'package:bmf_agent_app/features/savings/domain/models/saving_deposit.dart';
import 'package:bmf_agent_app/features/savings/domain/repositories/saving_repository.dart';
import 'package:bmf_agent_app/features/savings/presentation/bloc/saving_bloc.dart';
import 'package:bmf_agent_app/features/savings/presentation/bloc/saving_event.dart';
import 'package:bmf_agent_app/features/savings/presentation/bloc/saving_state.dart';

class FakeSavingRepository implements SavingRepository {
  bool shouldThrow = false;
  final List<SavingAccount> accounts = [];
  SavingDeposit? lastDeposit;

  @override
  Future<List<SavingAccount>> getSavingAccounts({String? centerCode, String? query}) async {
    if (shouldThrow) throw Exception('Database error loading savings accounts');
    var res = List<SavingAccount>.from(accounts);
    if (centerCode != null && centerCode.isNotEmpty) {
      res = res.where((a) => a.centerCode == centerCode).toList();
    }
    if (query != null && query.isNotEmpty) {
      res = res.where((a) => a.customerName.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return res;
  }

  @override
  Future<SavingDeposit> depositSaving(SavingDeposit deposit) async {
    if (shouldThrow) throw Exception('Failed to record deposit');
    final index = accounts.indexWhere((a) => a.accountNumber == deposit.accountNumber);
    double newBalance = deposit.amountMmk;
    if (index != -1) {
      newBalance = accounts[index].balanceMmk + deposit.amountMmk;
      accounts[index] = accounts[index].copyWith(balanceMmk: newBalance);
    }
    lastDeposit = SavingDeposit(
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
    return lastDeposit!;
  }

  @override
  Future<SavingAccount> openSavingAccount(SavingAccount account, {double initialDepositMmk = 0.0}) async {
    if (shouldThrow) throw Exception('Failed to open account');
    final updated = account.copyWith(balanceMmk: initialDepositMmk);
    accounts.add(updated);
    return updated;
  }
}

void main() {
  group('SavingBloc & Village Savings Tests (TASK-AGENT-08.1 & 08.2)', () {
    late FakeSavingRepository repository;
    late SavingBloc bloc;

    final testAccount = SavingAccount(
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
    );

    setUp(() {
      repository = FakeSavingRepository();
      repository.accounts.add(testAccount);
      bloc = SavingBloc(savingRepository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is SavingInitial', () {
      expect(bloc.state, isA<SavingInitial>());
    });

    test('LoadSavingAccountsRequested emits [SavingLoading, SavingLoaded]', () async {
      bloc.add(const LoadSavingAccountsRequested(centerCode: 'C001'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SavingLoading>(),
          predicate<SavingLoaded>((s) {
            return s.accounts.length == 1 && s.accounts.first.customerName == 'Daw Khin Khin Win';
          }),
        ]),
      );
    });

    test('DepositSavingRequested updates account balance and emits [SavingDepositSuccessState, SavingLoaded]', () async {
      bloc.add(
        const DepositSavingRequested(
          accountNumber: 'SAV-2026-00891',
          customerName: 'Daw Khin Khin Win',
          amountMmk: 50000.0,
          officerId: 'OFFICER001',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<SavingDepositSuccessState>((s) {
            return s.deposit.amountMmk == 50000.0 && s.deposit.newBalanceMmk == 300000.0;
          }),
          predicate<SavingLoaded>((s) {
            return s.accounts.first.balanceMmk == 300000.0;
          }),
        ]),
      );

      expect(repository.lastDeposit, isNotNull);
      expect(repository.lastDeposit!.newBalanceMmk, 300000.0);
    });

    test('OpenSavingAccountRequested creates passbook and emits [SavingLoading, SavingOpenSuccessState, SavingLoaded]', () async {
      final newPassbook = SavingAccount(
        accountId: 'SA002',
        accountNumber: 'SAV-2026-00999',
        centerCode: 'C001',
        groupCode: 'G001',
        customerName: 'Daw Nilar Myint',
        nrcFormatted: '12/DAGANA(N)234567',
        phone: '09234567890',
        productType: SavingProductType.voluntary,
        balanceMmk: 0.0,
        interestRateAnnual: 12.0,
        openedDate: DateTime.now(),
        nomineeName: 'Ko Aung Kyaw',
      );

      bloc.add(
        OpenSavingAccountRequested(
          account: newPassbook,
          initialDepositMmk: 20000.0,
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SavingLoading>(),
          predicate<SavingOpenSuccessState>((s) {
            return s.account.customerName == 'Daw Nilar Myint' && s.account.balanceMmk == 20000.0;
          }),
          predicate<SavingLoaded>((s) {
            return s.accounts.length == 2;
          }),
        ]),
      );

      expect(repository.accounts.length, 2);
    });

    test('SavingError emitted on repository failure', () async {
      repository.shouldThrow = true;
      bloc.add(const LoadSavingAccountsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SavingLoading>(),
          isA<SavingError>(),
        ]),
      );
    });
  });
}
