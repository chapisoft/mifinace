import 'package:equatable/equatable.dart';
import '../../../../core/enums/claim_risk_type.dart';
import '../../../../core/enums/claim_status.dart';

/// Entity representing a mutual micro-insurance emergency claim submitted from the village.
class InsuranceClaim extends Equatable {
  final String claimId;
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
  final DateTime createdAt;
  final ClaimStatus status;
  final String idempotencyKey;

  const InsuranceClaim({
    required this.claimId,
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
    required this.createdAt,
    required this.status,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'claimId': claimId,
      'memberNrc': memberNrc,
      'memberName': memberName,
      'centerCode': centerCode,
      'groupCode': groupCode,
      'phone': phone,
      'riskType': riskType.code,
      'incidentDate': incidentDate.toIso8601String(),
      'description': description,
      'requestedAmountMmk': requestedAmountMmk,
      'villageHeadLetterPhotoPath': villageHeadLetterPhotoPath,
      'medicalReceiptPhotoPath': medicalReceiptPhotoPath,
      'createdAt': createdAt.toIso8601String(),
      'status': status.code,
      'idempotencyKey': idempotencyKey,
    };
  }

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) {
    return InsuranceClaim(
      claimId: json['claimId'] as String,
      memberNrc: json['memberNrc'] as String,
      memberName: json['memberName'] as String,
      centerCode: json['centerCode'] as String,
      groupCode: json['groupCode'] as String,
      phone: json['phone'] as String? ?? '',
      riskType: ClaimRiskType.fromCode(json['riskType'] as String?),
      incidentDate: DateTime.parse(json['incidentDate'] as String),
      description: json['description'] as String? ?? '',
      requestedAmountMmk: (json['requestedAmountMmk'] as num).toDouble(),
      villageHeadLetterPhotoPath: json['villageHeadLetterPhotoPath'] as String?,
      medicalReceiptPhotoPath: json['medicalReceiptPhotoPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: ClaimStatus.fromCode(json['status'] as String?),
      idempotencyKey: json['idempotencyKey'] as String,
    );
  }

  @override
  List<Object?> get props => [
        claimId,
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
        createdAt,
        status,
        idempotencyKey,
      ];
}
