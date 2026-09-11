import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmf_customer/features/savings/domain/models/customer_saving_account.dart';
import 'package:bmf_customer/features/savings/domain/repositories/savings_repository.dart';
import 'package:bmf_customer/features/savings/presentation/bloc/savings_bloc.dart';
import 'package:bmf_customer/features/savings/presentation/bloc/savings_event.dart';
import 'package:bmf_customer/features/savings/presentation/bloc/savings_state.dart';

class MockSavingsRepository extends Mock implements SavingsRepository {}

void main() {
  late MockSavingsRepository mockSavingsRepository;
  late SavingsBloc savingsBloc;

  final testAccounts = [
    CustomerSavingAccount(
      accountId: 'SAV-001',
      accountNumber: 'BMF-SAV-098231',
      savingType: SavingType.compulsory,
      balanceMmk: 120000.0,
      accruedInterestMmk: 4800.0,
      interestRateAnnual: 8.0,
      openedDate: DateTime(2025, 6, 1),
      tenureMonths: 12,
    ),
    CustomerSavingAccount(
      accountId: 'SAV-002',
      accountNumber: 'BMF-SAV-114920',
      savingType: SavingType.voluntary,
      balanceMmk: 250000.0,
      accruedInterestMmk: 12500.0,
      interestRateAnnual: 10.0,
      openedDate: DateTime(2025, 9, 15),
      tenureMonths: 0,
    ),
  ];

  final newAccount = CustomerSavingAccount(
    accountId: 'SAV-003',
    accountNumber: 'BMF-FIX-999111',
    savingType: SavingType.fixedTerm,
    balanceMmk: 100000.0,
    accruedInterestMmk: 0.0,
    interestRateAnnual: 14.0,
    openedDate: DateTime(2026, 3, 1),
    maturityDate: DateTime(2027, 3, 1),
    tenureMonths: 12,
  );

  setUp(() {
    mockSavingsRepository = MockSavingsRepository();
    savingsBloc = SavingsBloc(savingsRepository: mockSavingsRepository);
  });

  tearDown(() {
    savingsBloc.close();
  });

  group('SavingsBloc Tests', () {
    test('Initial state should be SavingsInitial', () {
      expect(savingsBloc.state, isA<SavingsInitial>());
    });

    test('LoadSavingsAccountsRequested emits SavingsLoaded with passbooks', () async {
      when(() => mockSavingsRepository.getSavingAccounts('12/DAGAMA(N)098765'))
          .thenAnswer((_) async => testAccounts);

      savingsBloc.add(const LoadSavingsAccountsRequested('12/DAGAMA(N)098765'));

      await expectLater(
        savingsBloc.stream,
        emitsInOrder([
          const SavingsLoading(),
          isA<SavingsLoaded>().having(
            (s) => s.accounts.length,
            'accounts.length',
            2,
          ).having(
            (s) => s.totalSavingsBalanceMmk,
            'totalSavingsBalanceMmk',
            370000.0,
          ).having(
            (s) => s.totalAccruedInterestMmk,
            'totalAccruedInterestMmk',
            17300.0,
          ),
        ]),
      );
    });

    test('LoadSavingsAccountsRequested emits SavingsFailure when repository throws', () async {
      when(() => mockSavingsRepository.getSavingAccounts('12/DAGAMA(N)098765'))
          .thenThrow(Exception('Failed to connect to savings core'));

      savingsBloc.add(const LoadSavingsAccountsRequested('12/DAGAMA(N)098765'));

      await expectLater(
        savingsBloc.stream,
        emitsInOrder([
          const SavingsLoading(),
          isA<SavingsFailure>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Failed to connect to savings core'),
          ),
        ]),
      );
    });

    test('OpenSavingAccountRequested emits SavingAccountOpenedSuccess on success', () async {
      when(() => mockSavingsRepository.openFixedTermSaving(
            memberNrc: '12/DAGAMA(N)098765',
            initialDepositMmk: 100000.0,
            tenureMonths: 12,
            beneficiaryName: 'U Mg Mg',
          )).thenAnswer((_) async => newAccount);

      savingsBloc.add(const OpenSavingAccountRequested(
        memberNrc: '12/DAGAMA(N)098765',
        initialDepositMmk: 100000.0,
        tenureMonths: 12,
        beneficiaryName: 'U Mg Mg',
      ));

      await expectLater(
        savingsBloc.stream,
        emitsInOrder([
          const SavingsLoading(),
          isA<SavingAccountOpenedSuccess>().having(
            (s) => s.newAccount.accountNumber,
            'accountNumber',
            'BMF-FIX-999111',
          ).having(
            (s) => s.newAccount.interestRateAnnual,
            'interestRateAnnual',
            14.0,
          ),
        ]),
      );
    });
  });
}
