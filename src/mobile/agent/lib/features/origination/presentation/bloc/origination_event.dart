import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/loan_purpose_type.dart';
import '../../../../core/enums/survey_photo_type.dart';
import '../../domain/models/gps_location.dart';
import '../../domain/models/loan_application.dart';
import '../../domain/models/nrc_data.dart';
import '../../domain/models/survey_photo.dart';

abstract class OriginationEvent extends Equatable {
  const OriginationEvent();

  @override
  List<Object?> get props => [];
}

class NrcScannedEvent extends OriginationEvent {
  final NrcData nrcData;

  const NrcScannedEvent(this.nrcData);

  @override
  List<Object?> get props => [nrcData];
}

class GpsAcquiredEvent extends OriginationEvent {
  final GpsLocation location;

  const GpsAcquiredEvent(this.location);

  @override
  List<Object?> get props => [location];
}

class PhotoAddedEvent extends OriginationEvent {
  final SurveyPhoto photo;

  const PhotoAddedEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}

class SignatureCapturedEvent extends OriginationEvent {
  final Uint8List signatureBytes;

  const SignatureCapturedEvent(this.signatureBytes);

  @override
  List<Object?> get props => [signatureBytes];
}

class SubmitLoanApplicationRequested extends OriginationEvent {
  final String centerCode;
  final String groupCode;
  final String customerName;
  final String phone;
  final NrcData nrcData;
  final double requestedAmount;
  final int requestedTermMonths;
  final LoanPurposeType purposeType;
  final GpsLocation gpsLocation;
  final List<SurveyPhoto> surveyPhotos;
  final String? base64Signature;
  final String officerId;

  const SubmitLoanApplicationRequested({
    required this.centerCode,
    required this.groupCode,
    required this.customerName,
    required this.phone,
    required this.nrcData,
    required this.requestedAmount,
    required this.requestedTermMonths,
    required this.purposeType,
    required this.gpsLocation,
    required this.surveyPhotos,
    this.base64Signature,
    required this.officerId,
  });

  @override
  List<Object?> get props => [
        centerCode,
        groupCode,
        customerName,
        phone,
        nrcData,
        requestedAmount,
        requestedTermMonths,
        purposeType,
        gpsLocation,
        surveyPhotos,
        base64Signature,
        officerId,
      ];
}
