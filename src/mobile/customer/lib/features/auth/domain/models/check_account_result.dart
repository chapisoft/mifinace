import 'package:equatable/equatable.dart';

/// Kết quả kiểm tra tài khoản từ Core Banking và ứng dụng di động.
class CheckAccountResult extends Equatable {
  final String status; // 'ACTIVATED' | 'NOT_ACTIVATED'
  final String identifier;
  final String businessId;
  final String userType;
  final String fullName;
  final String maskedPhone;
  final String nrcNumber;
  final bool activated;
  final bool biometricEnabled;
  final bool pinLocked;

  const CheckAccountResult({
    required this.status,
    required this.identifier,
    required this.businessId,
    required this.userType,
    required this.fullName,
    required this.maskedPhone,
    required this.nrcNumber,
    required this.activated,
    required this.biometricEnabled,
    required this.pinLocked,
  });

  bool get isNotActivated => status == 'NOT_ACTIVATED' || !activated;
  bool get isActivated => status == 'ACTIVATED' || activated;
  String get nrcFormatted => nrcNumber;

  factory CheckAccountResult.fromJson(Map<String, dynamic> json) {
    return CheckAccountResult(
      status: json['status']?.toString() ?? 'NOT_ACTIVATED',
      identifier: json['identifier']?.toString() ?? '',
      businessId: json['businessId']?.toString() ?? '',
      userType: json['userType']?.toString() ?? 'CUSTOMER',
      fullName: json['fullName']?.toString() ?? '',
      maskedPhone: json['maskedPhone']?.toString() ?? '',
      nrcNumber: json['nrcNumber']?.toString() ?? '',
      activated: json['activated'] == true,
      biometricEnabled: json['biometricEnabled'] == true,
      pinLocked: json['pinLocked'] == true,
    );
  }

  @override
  List<Object?> get props => [
        status,
        identifier,
        businessId,
        userType,
        fullName,
        maskedPhone,
        nrcNumber,
        activated,
        biometricEnabled,
        pinLocked,
      ];
}
