import 'package:equatable/equatable.dart';
import '../../../../core/enums/loan_purpose_type.dart';
import '../../../../core/enums/sync_status.dart';
import 'gps_location.dart';
import 'nrc_data.dart';
import 'survey_photo.dart';

/// Entity representing a complete field microfinance loan application origination dossier.
class LoanApplication extends Equatable {
  final String applicationId;
  final String centerCode;
  final String groupCode;
  final String customerName;
  final String phone;
  final NrcData nrcData;
  final double requestedAmount; // MMK
  final int requestedTermMonths;
  final LoanPurposeType purposeType;
  final GpsLocation villageGpsLocation;
  final List<SurveyPhoto> surveyPhotos;
  final String? base64Signature;
  final String officerId;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  final String idempotencyKey;

  const LoanApplication({
    required this.applicationId,
    required this.centerCode,
    required this.groupCode,
    required this.customerName,
    required this.phone,
    required this.nrcData,
    required this.requestedAmount,
    required this.requestedTermMonths,
    required this.purposeType,
    required this.villageGpsLocation,
    required this.surveyPhotos,
    this.base64Signature,
    required this.officerId,
    required this.createdAt,
    required this.syncStatus,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'centerCode': centerCode,
      'groupCode': groupCode,
      'customerName': customerName,
      'phone': phone,
      'nrcFormatted': nrcData.fullNrcFormatted,
      'nrcStateNumber': nrcData.stateNumber,
      'nrcTownshipCode': nrcData.townshipCode,
      'nrcCitizenshipType': nrcData.citizenshipType.code,
      'nrcNumber': nrcData.nrcNumber,
      'requestedAmount': requestedAmount,
      'requestedTermMonths': requestedTermMonths,
      'purposeCode': purposeType.code,
      'villageGps': villageGpsLocation.toJson(),
      'surveyPhotos': surveyPhotos.map((p) => p.toJson()).toList(),
      'hasSignature': base64Signature != null,
      'officerId': officerId,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus.code,
      'idempotencyKey': idempotencyKey,
    };
  }

  @override
  List<Object?> get props => [
        applicationId,
        centerCode,
        groupCode,
        customerName,
        phone,
        nrcData,
        requestedAmount,
        requestedTermMonths,
        purposeType,
        villageGpsLocation,
        surveyPhotos,
        base64Signature,
        officerId,
        createdAt,
        syncStatus,
        idempotencyKey,
      ];
}
