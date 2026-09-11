import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/debt_group.dart';
import 'package:bmf_agent_app/core/enums/repayment_method.dart';
import 'package:bmf_agent_app/core/enums/repayment_status.dart';
import 'package:bmf_agent_app/core/enums/sync_status.dart';
import 'package:bmf_agent_app/features/collection/domain/entities/repayment_receipt.dart';
import 'package:bmf_agent_app/features/collection/domain/entities/schedule_item.dart';
import 'package:bmf_agent_app/features/collection/domain/repositories/collection_repository.dart';
import 'package:bmf_agent_app/features/collection/presentation/bloc/collection_bloc.dart';
import 'package:bmf_agent_app/features/collection/presentation/bloc/collection_event.dart';
import 'package:bmf_agent_app/features/collection/presentation/bloc/collection_state.dart';

class MockCollectionRepository implements CollectionRepository {
  bool shouldThrowError = false;

  final List<ScheduleItem> mockSchedules = [
    ScheduleItem(
      scheduleId: 'SCH_001',
      contractCode: 'LON-2026-001',
      customerCode: 'CUST001',
      customerName: 'Daw Khin Khin',
      groupCode: 'G001',
      periodNumber: 1,
      principalAmount: 45000.0,
      interestAmount: 5000.0,
      insuranceFee: 1000.0,
      compulsorySaving: 2000.0,
      totalAmount: 53000.0,
      dueDate: DateTime.parse('2026-09-15T00:00:00Z'),
      status: RepaymentStatus.pending,
      debtGroup: DebtGroup.standard,
    ),
  ];

  @override
  Future<List<ScheduleItem>> getSchedulesByGroup(String groupCode, {bool forceRefresh = false}) async {
    if (shouldThrowError) {
      throw Exception('Failed to load schedules');
    }
    return mockSchedules;
  }

  @override
  Future<RepaymentReceipt> collectRepayment({
    required ScheduleItem schedule,
    required double collectedAmount,
    required RepaymentMethod paymentMethod,
    required String collectorId,
  }) async {
    if (shouldThrowError) {
      throw Exception('Database lock or transaction error');
    }
    return RepaymentReceipt(
      transactionId: 'TXN-LOCAL-001',
      contractCode: schedule.contractCode,
      periodNumber: schedule.periodNumber,
      customerCode: schedule.customerCode,
      customerName: schedule.customerName,
      principalAmount: schedule.principalAmount,
      interestAmount: schedule.interestAmount,
      insuranceFee: schedule.insuranceFee,
      compulsorySaving: schedule.compulsorySaving,
      totalAmount: collectedAmount,
      paymentMethod: paymentMethod,
      receiptNumber: 'RCPT-2026-001',
      collectorId: collectorId,
      collectedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
      idempotencyKey: 'IDEMP-001',
    );
  }
}

void main() {
  group('CollectionBloc Tests (TASK-AGENT-04.3 & 04.4)', () {
    late MockCollectionRepository mockCollectionRepository;
    late CollectionBloc collectionBloc;

    setUp(() {
      mockCollectionRepository = MockCollectionRepository();
      collectionBloc = CollectionBloc(collectionRepository: mockCollectionRepository);
    });

    tearDown(() {
      collectionBloc.close();
    });

    test('Initial state is CollectionInitial', () {
      expect(collectionBloc.state, equals(const CollectionInitial()));
    });

    test('LoadSchedulesRequested emits [CollectionLoading, CollectionLoaded] with total due amounts', () async {
      final expectedStates = [
        const CollectionLoading(),
        isA<CollectionLoaded>()
            .having((s) => s.schedules.length, 'schedules count', 1)
            .having((s) => s.totalDueAmount, 'totalDueAmount', 53000.0)
            .having((s) => s.totalCollectedAmount, 'totalCollectedAmount', 0.0),
      ];

      expectLater(collectionBloc.stream, emitsInOrder(expectedStates));

      collectionBloc.add(const LoadSchedulesRequested('G001'));
    });

    test('SubmitRepaymentRequested records payment and emits RepaymentSuccessState', () async {
      final schedule = mockCollectionRepository.mockSchedules.first;

      final expectedStates = [
        isA<RepaymentSuccessState>().having(
          (s) => s.receipt.receiptNumber,
          'receiptNumber',
          'RCPT-2026-001',
        ),
        const CollectionLoading(),
        isA<CollectionLoaded>(),
      ];

      expectLater(collectionBloc.stream, emitsInOrder(expectedStates));

      collectionBloc.add(SubmitRepaymentRequested(
        schedule: schedule,
        amount: 53000.0,
        method: RepaymentMethod.cash,
        collectorId: 'OFFICER001',
      ));
    });
  });
}
