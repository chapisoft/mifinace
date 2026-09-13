import 'package:equatable/equatable.dart';

/// Entity representing an authenticated village borrower member profile.
class MemberProfile extends Equatable {
  final String memberId;
  final String customerCode;
  final String nrcFormatted;
  final String fullName;
  final String phone;
  final String centerName;
  final String groupName;
  final double totalSavingBalanceMmk;
  final int loyaltyPoints;
  final bool hasActiveLoans;
  final bool isPinConfigured;

  const MemberProfile({
    required this.memberId,
    String? customerCode,
    required this.nrcFormatted,
    required this.fullName,
    required this.phone,
    required this.centerName,
    required this.groupName,
    required this.totalSavingBalanceMmk,
    required this.loyaltyPoints,
    required this.hasActiveLoans,
    required this.isPinConfigured,
  }) : customerCode = customerCode ?? memberId;

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'customerCode': customerCode,
      'nrcFormatted': nrcFormatted,
      'fullName': fullName,
      'phone': phone,
      'centerName': centerName,
      'groupName': groupName,
      'totalSavingBalanceMmk': totalSavingBalanceMmk,
      'loyaltyPoints': loyaltyPoints,
      'hasActiveLoans': hasActiveLoans,
      'isPinConfigured': isPinConfigured,
    };
  }

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      memberId: (json['memberId'] ?? json['userId'] ?? '').toString(),
      customerCode: (json['customerCode'] ?? json['userId'] ?? json['memberId'] ?? '').toString(),
      nrcFormatted: (json['nrcFormatted'] ?? json['nrcNumber'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      centerName: (json['centerName'] ?? json['centerCode'] ?? '').toString(),
      groupName: (json['groupName'] ?? json['groupCode'] ?? '').toString(),
      totalSavingBalanceMmk: (json['totalSavingBalanceMmk'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      hasActiveLoans: json['hasActiveLoans'] as bool? ?? false,
      isPinConfigured: json['isPinConfigured'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        memberId,
        customerCode,
        nrcFormatted,
        fullName,
        phone,
        centerName,
        groupName,
        totalSavingBalanceMmk,
        loyaltyPoints,
        hasActiveLoans,
        isPinConfigured,
      ];
}
