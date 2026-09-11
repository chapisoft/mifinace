import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/claim_risk_type.dart';
import 'package:bmf_agent_app/core/enums/claim_status.dart';
import 'package:bmf_agent_app/features/insurance/domain/models/insurance_claim.dart';
import 'package:bmf_agent_app/features/insurance/domain/repositories/insurance_claim_repository.dart';
import 'package:bmf_agent_app/features/insurance/presentation/bloc/insurance_claim_bloc.dart';
import 'package:bmf_agent_app/features/insurance/presentation/bloc/insurance_claim_event.dart';
import 'package:bmf_agent_app/features/insurance/presentation/bloc/insurance_claim_state.dart';

class FakeInsuranceClaimRepository implements InsuranceClaimRepository {
  bool shouldThrow = false;
  final List<InsuranceClaim> claims = [];
  InsuranceClaim? lastSubmitted;

  @override
  Future<InsuranceClaim> submitClaim(InsuranceClaim claim) async {
    if (shouldThrow) throw Exception('Failed to record insurance claim');
    lastSubmitted = claim;
    claims.add(claim);
    return claim;
  }

  @override
  Future<List<InsuranceClaim>> getClaims({String? memberNrc, String? centerCode}) async {
    if (shouldThrow) throw Exception('Database error retrieving claims');
    var res = List<InsuranceClaim>.from(claims);
    if (memberNrc != null && memberNrc.isNotEmpty) {
      res = res.where((c) => c.memberNrc == memberNrc).toList();
    }
    return res;
  }
}

void main() {
  group('InsuranceClaimBloc & Village Mutual Claims Tests (TASK-AGENT-08.3)', () {
    late FakeInsuranceClaimRepository repository;
    late InsuranceClaimBloc bloc;

    final testClaim = InsuranceClaim(
      claimId: 'CLAIM-2026-0001',
      memberNrc: '12/DAGANA(N)123456',
      memberName: 'Daw Khin Khin Win',
      centerCode: 'C001',
      groupCode: 'G001',
      phone: '09123456789',
      riskType: ClaimRiskType.illness,
      incidentDate: DateTime(2026, 3, 1),
      description: 'Acute fever and hospitalized for 4 days',
      requestedAmountMmk: 150000.0,
      createdAt: DateTime.now(),
      status: ClaimStatus.submitted,
      idempotencyKey: 'IDEMP-CLAIM-001',
    );

    setUp(() {
      repository = FakeInsuranceClaimRepository();
      repository.claims.add(testClaim);
      bloc = InsuranceClaimBloc(claimRepository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is InsuranceClaimInitial', () {
      expect(bloc.state, isA<InsuranceClaimInitial>());
    });

    test('LoadClaimsRequested emits [InsuranceClaimLoading, InsuranceClaimLoaded]', () async {
      bloc.add(const LoadClaimsRequested(memberNrc: '12/DAGANA(N)123456'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<InsuranceClaimLoading>(),
          predicate<InsuranceClaimLoaded>((s) {
            return s.claims.length == 1 && s.claims.first.claimId == 'CLAIM-2026-0001';
          }),
        ]),
      );
    });

    test('SubmitClaimRequested creates new claim and emits [InsuranceClaimLoading, InsuranceClaimSubmittedState, InsuranceClaimLoaded]', () async {
      bloc.add(
        SubmitClaimRequested(
          memberNrc: '12/DAGANA(N)234567',
          memberName: 'Daw Nilar Myint',
          centerCode: 'C001',
          groupCode: 'G001',
          phone: '09234567890',
          riskType: ClaimRiskType.naturalDisaster,
          incidentDate: DateTime.now(),
          description: 'Flash flood damaged paddy storehouse',
          requestedAmountMmk: 250000.0,
          villageHeadLetterPhotoPath: '/data/user/photos/letter.jpg',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<InsuranceClaimLoading>(),
          predicate<InsuranceClaimSubmittedState>((s) {
            return s.claim.memberName == 'Daw Nilar Myint' &&
                s.claim.riskType == ClaimRiskType.naturalDisaster &&
                s.claim.status == ClaimStatus.submitted &&
                s.claim.claimId.startsWith('CLAIM-');
          }),
          predicate<InsuranceClaimLoaded>((s) {
            return s.claims.length == 2;
          }),
        ]),
      );

      expect(repository.lastSubmitted, isNotNull);
      expect(repository.lastSubmitted!.requestedAmountMmk, 250000.0);
    });

    test('InsuranceClaimError emitted when repository throws exception', () async {
      repository.shouldThrow = true;
      bloc.add(const LoadClaimsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<InsuranceClaimLoading>(),
          isA<InsuranceClaimError>(),
        ]),
      );
    });
  });
}
