import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmf_customer/core/enums/debt_group.dart';
import 'package:bmf_customer/core/enums/loan_type.dart';
import 'package:bmf_customer/core/enums/repayment_status.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_schedule_item.dart';
import 'package:bmf_customer/features/loans/domain/repositories/customer_loan_repository.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';

class MockCustomerLoanRepository extends Mock implements CustomerLoanRepository {}

void main() {
  late MockCustomerLoanRepository mockLoanRepository;
  late CustomerLoanBloc loanBloc;

  final testLoans = [
    CustomerLoan(
      loanId: 'LN-2026-001',
      contractCode: 'AGRI-KYA-001',
      customerCode: 'CUST-001',
      loanType: LoanType.agricultureSeasonal,
      disbursedAmountMmk: 500000.0,
      totalRepaidMmk: 200000.0,
      remainingPrincipalMmk: 300000.0,
      interestRateAnnual: 28.0,
      disbursedDate: DateTime(2026, 1, 15),
      maturityDate: DateTime(2027, 1, 15),
      totalPeriods: 12,
      paidPeriods: 4,
      debtGroup: DebtGroup.current,
      nextDueDate: DateTime.now().add(const Duration(days: 2)),
      nextDueAmountMmk: 48000.0,
      isDueSoon: true,
    ),
  ];

  final testSchedule = [
    CustomerScheduleItem(
      scheduleId: 'SCH-001',
      periodNumber: 1,
      dueDate: DateTime(2026, 2, 15),
      principalDueMmk: 40000.0,
      interestDueMmk: 7000.0,
      insuranceFeeMmk: 500.0,
      savingFeeMmk: 1000.0,
      totalDueMmk: 48500.0,
      status: RepaymentStatus.paid,
      paidDate: DateTime(2026, 2, 14),
      overdueDays: 0,
      debtGroup: DebtGroup.current,
    ),
    CustomerScheduleItem(
      scheduleId: 'SCH-002',
      periodNumber: 2,
      dueDate: DateTime(2026, 3, 15),
      principalDueMmk: 40000.0,
      interestDueMmk: 6800.0,
      insuranceFeeMmk: 500.0,
      savingFeeMmk: 1000.0,
      totalDueMmk: 48300.0,
      status: RepaymentStatus.dueToday,
      overdueDays: 0,
      debtGroup: DebtGroup.current,
    ),
  ];

  setUp(() {
    mockLoanRepository = MockCustomerLoanRepository();
    loanBloc = CustomerLoanBloc(loanRepository: mockLoanRepository);
  });

  tearDown(() {
    loanBloc.close();
  });

  group('CustomerLoanBloc Tests', () {
    test('Initial state should be LoanInitial', () {
      expect(loanBloc.state, isA<LoanInitial>());
    });

    test('LoadActiveLoansRequested emits loaded state with active loans', () async {
      when(() => mockLoanRepository.getActiveLoans('12/DAGAMA(N)098765'))
          .thenAnswer((_) async => testLoans);

      loanBloc.add(const LoadActiveLoansRequested('12/DAGAMA(N)098765'));

      await expectLater(
        loanBloc.stream,
        emitsInOrder([
          const LoanLoading(),
          isA<LoanListLoaded>().having(
            (s) => s.loans.length,
            'loans.length',
            1,
          ).having(
            (s) => s.loans.first.isDueSoon,
            'first.isDueSoon',
            isTrue,
          ).having(
            (s) => s.loans.first.completionProgress,
            'completionProgress',
            closeTo(0.33, 0.01),
          ),
        ]),
      );
    });

    test('LoadActiveLoansRequested emits error state when repository throws', () async {
      when(() => mockLoanRepository.getActiveLoans('12/DAGAMA(N)098765'))
          .thenThrow(Exception('Core Gateway connection failure'));

      loanBloc.add(const LoadActiveLoansRequested('12/DAGAMA(N)098765'));

      await expectLater(
        loanBloc.stream,
        emitsInOrder([
          const LoanLoading(),
          isA<LoanError>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Core Gateway connection failure'),
          ),
        ]),
      );
    });

    test('LoadLoanScheduleRequested emits loaded state with repayment schedule items', () async {
      when(() => mockLoanRepository.getLoanSchedule('AGRI-KYA-001'))
          .thenAnswer((_) async => testSchedule);

      loanBloc.add(const LoadLoanScheduleRequested('AGRI-KYA-001'));

      await expectLater(
        loanBloc.stream,
        emitsInOrder([
          const LoanLoading(),
          isA<LoanScheduleLoaded>().having(
            (s) => s.schedules.length,
            'schedules.length',
            2,
          ).having(
            (s) => s.schedules.first.status,
            'schedules[0].status',
            RepaymentStatus.paid,
          ),
        ]),
      );
    });

    test('LoadLoanScheduleRequested emits error state when repository throws', () async {
      when(() => mockLoanRepository.getLoanSchedule('AGRI-KYA-001'))
          .thenThrow(Exception('Database query timeout'));

      loanBloc.add(const LoadLoanScheduleRequested('AGRI-KYA-001'));

      await expectLater(
        loanBloc.stream,
        emitsInOrder([
          const LoanLoading(),
          isA<LoanError>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Database query timeout'),
          ),
        ]),
      );
    });
  });
}
