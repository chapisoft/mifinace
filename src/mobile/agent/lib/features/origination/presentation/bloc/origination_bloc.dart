import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/loan_application.dart';
import '../../domain/repositories/loan_origination_repository.dart';
import 'origination_event.dart';
import 'origination_state.dart';

/// Bloc managing loan origination lifecycle, NRC OCR validation, GPS survey photo aggregation, and e-Signature.
class OriginationBloc extends Bloc<OriginationEvent, OriginationState> {
  final LoanOriginationRepository _originationRepository;
  final Uuid _uuid;

  OriginationBloc({
    required LoanOriginationRepository originationRepository,
    Uuid? uuid,
  })  : _originationRepository = originationRepository,
        _uuid = uuid ?? const Uuid(),
        super(const OriginationDraftState()) {
    on<NrcScannedEvent>(_onNrcScanned);
    on<GpsAcquiredEvent>(_onGpsAcquired);
    on<PhotoAddedEvent>(_onPhotoAdded);
    on<SignatureCapturedEvent>(_onSignatureCaptured);
    on<SubmitLoanApplicationRequested>(_onSubmitApplication);
  }

  void _onNrcScanned(NrcScannedEvent event, Emitter<OriginationState> emit) {
    AppLogger.info('NRC scanned and attached to draft loan application: ${event.nrcData.fullNrcFormatted}', tag: 'OriginationBloc');
    if (state is OriginationDraftState) {
      emit((state as OriginationDraftState).copyWith(nrcData: event.nrcData));
    } else {
      emit(OriginationDraftState(nrcData: event.nrcData));
    }
  }

  void _onGpsAcquired(GpsAcquiredEvent event, Emitter<OriginationState> emit) {
    AppLogger.info('Village GPS location acquired: LAT=${event.location.latitude}, LON=${event.location.longitude}', tag: 'OriginationBloc');
    if (state is OriginationDraftState) {
      emit((state as OriginationDraftState).copyWith(gpsLocation: event.location));
    } else {
      emit(OriginationDraftState(gpsLocation: event.location));
    }
  }

  void _onPhotoAdded(PhotoAddedEvent event, Emitter<OriginationState> emit) {
    AppLogger.info('Survey photo added: ${event.photo.photoType.name}', tag: 'OriginationBloc');
    final updatedPhotos = List.of(state.surveyPhotos)..add(event.photo);
    if (state is OriginationDraftState) {
      emit((state as OriginationDraftState).copyWith(surveyPhotos: updatedPhotos));
    } else {
      emit(OriginationDraftState(surveyPhotos: updatedPhotos));
    }
  }

  void _onSignatureCaptured(SignatureCapturedEvent event, Emitter<OriginationState> emit) {
    AppLogger.info('Borrower e-Signature captured (${event.signatureBytes.length} bytes)', tag: 'OriginationBloc');
    if (state is OriginationDraftState) {
      emit((state as OriginationDraftState).copyWith(signatureBytes: event.signatureBytes));
    } else {
      emit(OriginationDraftState(signatureBytes: event.signatureBytes));
    }
  }

  Future<void> _onSubmitApplication(SubmitLoanApplicationRequested event, Emitter<OriginationState> emit) async {
    emit(OriginationSubmitting(
      nrcData: event.nrcData,
      gpsLocation: event.gpsLocation,
      surveyPhotos: event.surveyPhotos,
      signatureBytes: state.signatureBytes,
    ));

    try {
      final appId = 'APP-${DateTime.now().year}-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final idempotencyKey = _uuid.v4();
      final base64Signature = state.signatureBytes != null ? base64Encode(state.signatureBytes!) : null;

      final application = LoanApplication(
        applicationId: appId,
        centerCode: event.centerCode,
        groupCode: event.groupCode,
        customerName: event.customerName,
        phone: event.phone,
        nrcData: event.nrcData,
        requestedAmount: event.requestedAmount,
        requestedTermMonths: event.requestedTermMonths,
        purposeType: event.purposeType,
        villageGpsLocation: event.gpsLocation,
        surveyPhotos: event.surveyPhotos,
        base64Signature: base64Signature,
        officerId: event.officerId,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        idempotencyKey: idempotencyKey,
      );

      final submitted = await _originationRepository.submitLoanApplication(application);
      AppLogger.info('Loan origination submitted successfully: ${submitted.applicationId}', tag: 'OriginationBloc');
      emit(OriginationSuccessState(submitted));
    } catch (e, stack) {
      AppLogger.error('Failed to submit loan application: $e', tag: 'OriginationBloc', stackTrace: stack);
      emit(OriginationErrorState(
        e.toString(),
        nrcData: event.nrcData,
        gpsLocation: event.gpsLocation,
        surveyPhotos: event.surveyPhotos,
        signatureBytes: state.signatureBytes,
      ));
    }
  }
}
