import 'package:equatable/equatable.dart';
import '../../../../core/enums/claim_risk_type.dart';

abstract class InsuranceClaimEvent extends Equatable {
  const InsuranceClaimEvent();

  @override
  List<Object?> get props => [];
}

class LoadClaimsRequested extends InsuranceClaimEvent {
  final String? memberNrc;
  final String? centerCode;

  const LoadClaimsRequested({this.memberNrc, this.centerCode});

  @override
  List<Object?> get props => [memberNrc, centerCode];
}

class SubmitClaimRequested extends InsuranceClaimEvent {
  final String memberNrc;
  final String memberName;
  final String centerCode;
  final String groupCode;
  final String phone;
  final ClaimRiskType riskType;
  final DateTime incidentDate;
  final String description;
  final double requestedAmountMmk;
  final String? villageHeadLetterPhotoPath;
  final String? medicalReceiptPhotoPath;

  const SubmitClaimRequested({
    required this.memberNrc,
    required this.memberName,
    required this.centerCode,
    required this.groupCode,
    required this.phone,
    required this.riskType,
    required this.incidentDate,
    required this.description,
    required this.requestedAmountMmk,
    this.villageHeadLetterPhotoPath,
    this.medicalReceiptPhotoPath,
  });

  @override
  List<Object?> get props => [
        memberNrc,
        memberName,
        centerCode,
        groupCode,
        phone,
        riskType,
        incidentDate,
        description,
        requestedAmountMmk,
        villageHeadLetterPhotoPath,
        medicalReceiptPhotoPath,
      ];
}
