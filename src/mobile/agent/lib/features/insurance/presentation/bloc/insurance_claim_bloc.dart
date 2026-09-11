import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/claim_status.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/insurance_claim.dart';
import '../../domain/repositories/insurance_claim_repository.dart';
import 'insurance_claim_event.dart';
import 'insurance_claim_state.dart';

/// Bloc managing mutual micro-insurance claim intake, photo document upload, and status lookup.
class InsuranceClaimBloc extends Bloc<InsuranceClaimEvent, InsuranceClaimState> {
  final InsuranceClaimRepository _claimRepository;
  final Uuid _uuid;

  InsuranceClaimBloc({
    required InsuranceClaimRepository claimRepository,
    Uuid? uuid,
  })  : _claimRepository = claimRepository,
        _uuid = uuid ?? const Uuid(),
        super(const InsuranceClaimInitial()) {
    on<LoadClaimsRequested>(_onLoadClaims);
    on<SubmitClaimRequested>(_onSubmitClaim);
  }

  Future<void> _onLoadClaims(LoadClaimsRequested event, Emitter<InsuranceClaimState> emit) async {
    emit(const InsuranceClaimLoading());
    try {
      AppLogger.info('Loading insurance claims (nrc: ${event.memberNrc}, center: ${event.centerCode})', tag: 'ClaimBloc');
      final claims = await _claimRepository.getClaims(
        memberNrc: event.memberNrc,
        centerCode: event.centerCode,
      );
      emit(InsuranceClaimLoaded(claims));
    } catch (e, stack) {
      AppLogger.error('Failed to load insurance claims: $e', tag: 'ClaimBloc', stackTrace: stack);
      emit(InsuranceClaimError(e.toString()));
    }
  }

  Future<void> _onSubmitClaim(SubmitClaimRequested event, Emitter<InsuranceClaimState> emit) async {
    emit(const InsuranceClaimLoading());
    try {
      AppLogger.info(
        'Submitting mutual insurance claim for member ${event.memberName} (${event.riskType.name})',
        tag: 'ClaimBloc',
      );

      final claimId = 'CLAIM-${DateTime.now().year}-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final idempotencyKey = _uuid.v4();

      final claim = InsuranceClaim(
        claimId: claimId,
        memberNrc: event.memberNrc,
        memberName: event.memberName,
        centerCode: event.centerCode,
        groupCode: event.groupCode,
        phone: event.phone,
        riskType: event.riskType,
        incidentDate: event.incidentDate,
        description: event.description,
        requestedAmountMmk: event.requestedAmountMmk,
        villageHeadLetterPhotoPath: event.villageHeadLetterPhotoPath,
        medicalReceiptPhotoPath: event.medicalReceiptPhotoPath,
        createdAt: DateTime.now(),
        status: ClaimStatus.submitted,
        idempotencyKey: idempotencyKey,
      );

      final submitted = await _claimRepository.submitClaim(claim);
      AppLogger.info('Insurance claim successfully enqueued offline: ${submitted.claimId}', tag: 'ClaimBloc');
      emit(InsuranceClaimSubmittedState(submitted));

      final claims = await _claimRepository.getClaims();
      emit(InsuranceClaimLoaded(claims));
    } catch (e, stack) {
      AppLogger.error('Failed to submit insurance claim: $e', tag: 'ClaimBloc', stackTrace: stack);
      emit(InsuranceClaimError(e.toString()));
    }
  }
}
