import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/loan_purpose_type.dart';
import 'package:bmf_agent_app/core/enums/nrc_citizenship_type.dart';
import 'package:bmf_agent_app/core/enums/survey_photo_type.dart';
import 'package:bmf_agent_app/core/enums/sync_status.dart';
import 'package:bmf_agent_app/features/origination/domain/models/gps_location.dart';
import 'package:bmf_agent_app/features/origination/domain/models/loan_application.dart';
import 'package:bmf_agent_app/features/origination/domain/models/nrc_data.dart';
import 'package:bmf_agent_app/features/origination/domain/models/survey_photo.dart';
import 'package:bmf_agent_app/features/origination/domain/repositories/loan_origination_repository.dart';
import 'package:bmf_agent_app/features/origination/presentation/bloc/origination_bloc.dart';
import 'package:bmf_agent_app/features/origination/presentation/bloc/origination_event.dart';
import 'package:bmf_agent_app/features/origination/presentation/bloc/origination_state.dart';

class FakeLoanOriginationRepository implements LoanOriginationRepository {
  bool shouldThrow = false;
  LoanApplication? lastSubmitted;

  @override
  Future<LoanApplication> submitLoanApplication(LoanApplication application) async {
    if (shouldThrow) {
      throw Exception('Database write failure during loan origination');
    }
    lastSubmitted = application;
    return application;
  }

  @override
  Future<List<LoanApplication>> getPendingApplications() async {
    return lastSubmitted != null ? [lastSubmitted!] : [];
  }
}

void main() {
  group('OriginationBloc & Loan Origination Tests (TASK-AGENT-07)', () {
    late FakeLoanOriginationRepository repository;
    late OriginationBloc bloc;

    const testNrc = NrcData(
      stateNumber: 12,
      townshipCode: 'DAGANA',
      citizenshipType: NrcCitizenshipType.citizen,
      nrcNumber: '123456',
      fullNrcFormatted: '12/DAGANA(N)123456',
      myanmarFormatted: '၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆',
    );

    final testGps = GpsLocation(
      latitude: 20.789123,
      longitude: 97.034567,
      altitude: 1430.0,
      accuracy: 3.5,
      timestamp: DateTime.now(),
    );

    setUp(() {
      repository = FakeLoanOriginationRepository();
      bloc = OriginationBloc(originationRepository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is OriginationDraftState with empty fields', () {
      expect(bloc.state, isA<OriginationDraftState>());
      expect(bloc.state.nrcData, isNull);
      expect(bloc.state.gpsLocation, isNull);
      expect(bloc.state.surveyPhotos, isEmpty);
      expect(bloc.state.signatureBytes, isNull);
    });

    test('NrcScannedEvent updates draft state with parsed NRC', () async {
      bloc.add(const NrcScannedEvent(testNrc));
      await expectLater(
        bloc.stream,
        emits(predicate<OriginationState>((s) => s.nrcData?.fullNrcFormatted == '12/DAGANA(N)123456')),
      );
    });

    test('GpsAcquiredEvent updates draft state with GPS location', () async {
      bloc.add(GpsAcquiredEvent(testGps));
      await expectLater(
        bloc.stream,
        emits(predicate<OriginationState>((s) => s.gpsLocation?.latitude == 20.789123)),
      );
    });

    test('PhotoAddedEvent appends watermarked photo to surveyPhotos list', () async {
      final photo = SurveyPhoto(
        photoId: 'P001',
        photoType: SurveyPhotoType.houseFront,
        filePath: '/data/user/photos/house.jpg',
        gpsLocation: testGps,
        capturedAt: DateTime.now(),
        fileSizeBytes: 1024,
      );

      bloc.add(PhotoAddedEvent(photo));
      await expectLater(
        bloc.stream,
        emits(predicate<OriginationState>((s) => s.surveyPhotos.length == 1 && s.surveyPhotos.first.photoId == 'P001')),
      );
    });

    test('SignatureCapturedEvent updates draft state with raw signature bytes', () async {
      final dummySignature = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      bloc.add(SignatureCapturedEvent(dummySignature));
      await expectLater(
        bloc.stream,
        emits(predicate<OriginationState>((s) => s.signatureBytes?.length == 8)),
      );
    });

    test('SubmitLoanApplicationRequested submits application and emits [OriginationSubmitting, OriginationSuccessState]', () async {
      final dummySignature = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
      bloc.add(SignatureCapturedEvent(dummySignature));
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(
        SubmitLoanApplicationRequested(
          centerCode: 'C001',
          groupCode: 'G001',
          customerName: 'Daw Khin Khin Win',
          phone: '09123456789',
          nrcData: testNrc,
          requestedAmount: 1500000.0,
          requestedTermMonths: 12,
          purposeType: LoanPurposeType.agriculture,
          gpsLocation: testGps,
          surveyPhotos: const [],
          base64Signature: 'AQIDBA==',
          officerId: 'OFFICER001',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OriginationSubmitting>(),
          predicate<OriginationSuccessState>((s) {
            final app = s.application;
            return app.customerName == 'Daw Khin Khin Win' &&
                app.requestedAmount == 1500000.0 &&
                app.syncStatus == SyncStatus.pending &&
                app.idempotencyKey.isNotEmpty &&
                app.base64Signature != null;
          }),
        ]),
      );

      expect(repository.lastSubmitted, isNotNull);
      expect(repository.lastSubmitted!.customerName, 'Daw Khin Khin Win');
    });

    test('SubmitLoanApplicationRequested emits OriginationErrorState on repository failure', () async {
      repository.shouldThrow = true;

      bloc.add(
        SubmitLoanApplicationRequested(
          centerCode: 'C001',
          groupCode: 'G001',
          customerName: 'Daw Khin Khin Win',
          phone: '09123456789',
          nrcData: testNrc,
          requestedAmount: 1500000.0,
          requestedTermMonths: 12,
          purposeType: LoanPurposeType.agriculture,
          gpsLocation: testGps,
          surveyPhotos: const [],
          base64Signature: null,
          officerId: 'OFFICER001',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OriginationSubmitting>(),
          isA<OriginationErrorState>(),
        ]),
      );
    });
  });
}
