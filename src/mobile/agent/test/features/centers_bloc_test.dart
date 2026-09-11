import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/features/centers/domain/entities/center_item.dart';
import 'package:bmf_agent_app/features/centers/domain/entities/group_item.dart';
import 'package:bmf_agent_app/features/centers/domain/repositories/center_repository.dart';
import 'package:bmf_agent_app/features/centers/presentation/bloc/center_bloc.dart';
import 'package:bmf_agent_app/features/centers/presentation/bloc/center_event.dart';
import 'package:bmf_agent_app/features/centers/presentation/bloc/center_state.dart';

class MockCenterRepository implements CenterRepository {
  bool shouldThrowError = false;

  final List<CenterItem> mockCenters = const [
    CenterItem(
      centerId: 'C_001',
      centerCode: 'C001',
      centerName: 'Taunggyi Central Center',
      meetingDay: 'Monday',
      meetingTime: '09:00 AM',
      townshipCode: 'TGY',
      officerId: 'OFFICER001',
    ),
    CenterItem(
      centerId: 'C_002',
      centerCode: 'C002',
      centerName: 'Aungban Market Center',
      meetingDay: 'Tuesday',
      meetingTime: '10:30 AM',
      townshipCode: 'ABN',
      officerId: 'OFFICER001',
    ),
  ];

  final List<GroupItem> mockGroups = const [
    GroupItem(
      groupId: 'G_001',
      groupCode: 'G001',
      groupName: 'Group Lotus 1',
      centerCode: 'C001',
      leaderName: 'Daw Aye Aye',
      leaderPhone: '0912345678',
      memberCount: 5,
    ),
  ];

  @override
  Future<List<CenterItem>> getCenters({bool forceRefresh = false}) async {
    if (shouldThrowError) {
      throw Exception('Failed to load centers from database or API');
    }
    return mockCenters;
  }

  @override
  Future<List<GroupItem>> getGroupsByCenter(String centerCode, {bool forceRefresh = false}) async {
    if (shouldThrowError) {
      throw Exception('Failed to load groups');
    }
    return mockGroups.where((g) => g.centerCode == centerCode).toList();
  }
}

void main() {
  group('CenterBloc Tests (TASK-AGENT-04.1 & 04.2)', () {
    late MockCenterRepository mockCenterRepository;
    late CenterBloc centerBloc;

    setUp(() {
      mockCenterRepository = MockCenterRepository();
      centerBloc = CenterBloc(centerRepository: mockCenterRepository);
    });

    tearDown(() {
      centerBloc.close();
    });

    test('Initial state is CenterInitial', () {
      expect(centerBloc.state, equals(const CenterInitial()));
    });

    test('LoadCentersRequested emits [CenterLoading, CenterLoaded] on success', () async {
      final expectedStates = [
        const CenterLoading(),
        isA<CenterLoaded>().having((s) => s.centers.length, 'centers count', 2),
      ];

      expectLater(centerBloc.stream, emitsInOrder(expectedStates));

      centerBloc.add(const LoadCentersRequested());
    });

    test('LoadCentersRequested emits [CenterLoading, CenterError] on failure', () async {
      mockCenterRepository.shouldThrowError = true;

      final expectedStates = [
        const CenterLoading(),
        isA<CenterError>(),
      ];

      expectLater(centerBloc.stream, emitsInOrder(expectedStates));

      centerBloc.add(const LoadCentersRequested());
    });

    test('SelectCenterRequested loads groups and updates CenterLoaded with selectedCenter', () async {
      centerBloc.emit(CenterLoaded(centers: mockCenterRepository.mockCenters));

      final expectedStates = [
        isA<CenterLoaded>()
            .having((s) => s.selectedCenter?.centerCode, 'selectedCenter', 'C001')
            .having((s) => s.groups.length, 'groups count', 1),
      ];

      expectLater(centerBloc.stream, emitsInOrder(expectedStates));

      centerBloc.add(const SelectCenterRequested('C001'));
    });
  });
}
