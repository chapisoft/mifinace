import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/models/gps_location.dart';
import '../../domain/models/loan_application.dart';
import '../../domain/models/nrc_data.dart';
import '../../domain/models/survey_photo.dart';

abstract class OriginationState extends Equatable {
  final NrcData? nrcData;
  final GpsLocation? gpsLocation;
  final List<SurveyPhoto> surveyPhotos;
  final Uint8List? signatureBytes;

  const OriginationState({
    this.nrcData,
    this.gpsLocation,
    this.surveyPhotos = const [],
    this.signatureBytes,
  });

  @override
  List<Object?> get props => [nrcData, gpsLocation, surveyPhotos, signatureBytes];
}

class OriginationInitial extends OriginationState {
  const OriginationInitial() : super();
}

class OriginationDraftState extends OriginationState {
  const OriginationDraftState({
    super.nrcData,
    super.gpsLocation,
    super.surveyPhotos,
    super.signatureBytes,
  });

  OriginationDraftState copyWith({
    NrcData? nrcData,
    GpsLocation? gpsLocation,
    List<SurveyPhoto>? surveyPhotos,
    Uint8List? signatureBytes,
  }) {
    return OriginationDraftState(
      nrcData: nrcData ?? this.nrcData,
      gpsLocation: gpsLocation ?? this.gpsLocation,
      surveyPhotos: surveyPhotos ?? this.surveyPhotos,
      signatureBytes: signatureBytes ?? this.signatureBytes,
    );
  }
}

class OriginationSubmitting extends OriginationState {
  const OriginationSubmitting({
    super.nrcData,
    super.gpsLocation,
    super.surveyPhotos,
    super.signatureBytes,
  });
}

class OriginationSuccessState extends OriginationState {
  final LoanApplication application;

  const OriginationSuccessState(this.application);

  @override
  List<Object?> get props => [application];
}

class OriginationErrorState extends OriginationState {
  final String errorMessage;

  const OriginationErrorState(this.errorMessage, {
    super.nrcData,
    super.gpsLocation,
    super.surveyPhotos,
    super.signatureBytes,
  });

  @override
  List<Object?> get props => [errorMessage, nrcData, gpsLocation, surveyPhotos, signatureBytes];
}
