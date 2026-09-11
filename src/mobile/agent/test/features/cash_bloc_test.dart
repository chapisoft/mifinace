import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/cash_transaction_type.dart';
import 'package:bmf_agent_app/features/cash/domain/models/cash_entry.dart';
import 'package:bmf_agent_app/features/cash/domain/models/cash_summary.dart';
import 'package:bmf_agent_app/features/cash/domain/services/cash_management_service.dart';
import 'package:bmf_agent_app/features/cash/presentation/bloc/cash_bloc.dart';
import 'package:bmf_agent_app/features/cash/presentation/bloc/cash_event.dart';
import 'package:bmf_agent_app/features/cash/presentation/bloc/cash_state.dart';

class FakeCashManagementService implements CashManagementService {
  bool shouldThrow = false;
  final List<CashEntry> entries = [];
  static const double safeLimit = 5000000.0;

  @override
  Future<CashSummary> getCashSummary(String officerId) async {
    if (shouldThrow) throw Exception('Cash summary computation error');
    double repayments = 0;
    double savings = 0;
    double handedOver = 0;

    for (final e in entries) {
      if (e.transactionType == CashTransactionType.loanRepayment) {
        repayments += e.amountMmk;
      } else if (e.transactionType == CashTransactionType.savingDeposit ||
          e.transactionType == CashTransactionType.savingOpen) {
        savings += e.amountMmk;
      } else if (e.transactionType == CashTransactionType.handoverToCashier) {
        handedOver += e.amountMmk;
      }
    }

    final balance = (repayments + savings) - handedOver;
    return CashSummary(
      officerId: officerId,
      currentCashBalanceMmk: balance,
      totalRepaymentMmk: repayments,
      totalSavingMmk: savings,
      safeLimitMmk: safeLimit,
      isExceedingLimit: balance >= safeLimit,
      transactionCount: entries.where((e) => e.transactionType != CashTransactionType.handoverToCashier).length,
      entries: List.unmodifiable(entries),
    );
  }

  @override
  Future<void> recordCashEntry(CashEntry entry) async {
    entries.add(entry);
  }

  @override
  Future<String> generateHandoverQrPayload(String officerId) async {
    final summary = await getCashSummary(officerId);
    return jsonEncode({
      'type': 'BMF_CASH_HANDOVER',
      'officerId': officerId,
      'totalCashMmk': summary.currentCashBalanceMmk,
    });
  }

  @override
  Future<void> completeHandover(String officerId, String handoverReference) async {
    final summary = await getCashSummary(officerId);
    entries.add(CashEntry(
      entryId: 'HO-001',
      transactionType: CashTransactionType.handoverToCashier,
      referenceId: handoverReference,
      customerName: 'Branch Cashier Desk',
      amountMmk: summary.currentCashBalanceMmk,
      timestamp: DateTime.now(),
    ));
  }
}

void main() {
  group('CashBloc & Mobile Cash Management Tests (TASK-AGENT-08.4)', () {
    late FakeCashManagementService service;
    late CashBloc bloc;

    setUp(() {
      service = FakeCashManagementService();
      service.entries.addAll([
        CashEntry(
          entryId: 'CSH-01',
          transactionType: CashTransactionType.loanRepayment,
          referenceId: 'REC-001',
          customerName: 'Daw Khin Khin Win',
          amountMmk: 1250000.0,
          timestamp: DateTime.now(),
        ),
        CashEntry(
          entryId: 'CSH-02',
          transactionType: CashTransactionType.savingDeposit,
          referenceId: 'DEP-001',
          customerName: 'Daw Nilar Myint',
          amountMmk: 250000.0,
          timestamp: DateTime.now(),
        ),
      ]);
      bloc = CashBloc(cashService: service);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is CashInitial', () {
      expect(bloc.state, isA<CashInitial>());
    });

    test('LoadCashSummaryRequested calculates correct balance without exceeding threshold', () async {
      bloc.add(const LoadCashSummaryRequested(officerId: 'OFFICER001'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CashLoading>(),
          predicate<CashLoaded>((s) {
            return s.summary.currentCashBalanceMmk == 1500000.0 &&
                s.summary.totalRepaymentMmk == 1250000.0 &&
                s.summary.totalSavingMmk == 250000.0 &&
                s.summary.isExceedingLimit == false;
          }),
        ]),
      );
    });

    test('Detects isExceedingLimit when cash balance reaches 5,000,000 MMK threshold', () async {
      service.entries.add(
        CashEntry(
          entryId: 'CSH-03',
          transactionType: CashTransactionType.loanRepayment,
          referenceId: 'REC-003',
          customerName: 'U Aung Myo',
          amountMmk: 4000000.0,
          timestamp: DateTime.now(),
        ),
      );

      bloc.add(const LoadCashSummaryRequested(officerId: 'OFFICER001'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CashLoading>(),
          predicate<CashLoaded>((s) {
            return s.summary.currentCashBalanceMmk == 5500000.0 && s.summary.isExceedingLimit == true;
          }),
        ]),
      );
    });

    test('GenerateHandoverQrRequested creates valid QR payload for cashier', () async {
      bloc.add(const GenerateHandoverQrRequested(officerId: 'OFFICER001'));

      await expectLater(
        bloc.stream,
        emits(
          predicate<CashHandoverQrGeneratedState>((s) {
            final parsed = jsonDecode(s.qrPayload) as Map<String, dynamic>;
            return parsed['type'] == 'BMF_CASH_HANDOVER' && parsed['officerId'] == 'OFFICER001';
          }),
        ),
      );
    });

    test('ConfirmHandoverCompletedRequested completes handover and zeroes out cash balance', () async {
      bloc.add(
        const ConfirmHandoverCompletedRequested(
          officerId: 'OFFICER001',
          referenceId: 'REF-VAULT-999',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CashLoading>(),
          predicate<CashHandoverSuccessState>((s) => s.referenceId == 'REF-VAULT-999'),
          predicate<CashLoaded>((s) => s.summary.currentCashBalanceMmk == 0.0),
        ]),
      );
    });

    test('CashError emitted when cash service throws exception', () async {
      service.shouldThrow = true;
      bloc.add(const LoadCashSummaryRequested(officerId: 'OFFICER001'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CashLoading>(),
          isA<CashError>(),
        ]),
      );
    });
  });
}
