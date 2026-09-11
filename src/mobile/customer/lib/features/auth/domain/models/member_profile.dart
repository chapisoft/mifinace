import 'package:equatable/equatable.dart';

/// Entity representing an authenticated village borrower member profile.
class MemberProfile extends Equatable {
  final String memberId;
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
    required this.nrcFormatted,
    required this.fullName,
    required this.phone,
    required this.centerName,
    required this.groupName,
    required this.totalSavingBalanceMmk,
    required this.loyaltyPoints,
    required this.hasActiveLoans,
    required this.isPinConfigured,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
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
      memberId: json['memberId'] as String,
      nrcFormatted: json['nrcFormatted'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      centerName: json['centerName'] as String,
      groupName: json['groupName'] as String,
      totalSavingBalanceMmk: (json['totalSavingBalanceMmk'] as num).toDouble(),
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
      hasActiveLoans: json['hasActiveLoans'] as bool? ?? false,
      isPinConfigured: json['isPinConfigured'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        memberId,
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
