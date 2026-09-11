import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_role.dart';

/// Entity representing an authenticated Credit Officer Profile.
class OfficerProfile extends Equatable {
  final String userId;
  final String username;
  final String fullName;
  final String? branchCode;
  final String? branchName;
  final String? townshipCode;
  final UserRole role;

  const OfficerProfile({
    required this.userId,
    required this.username,
    required this.fullName,
    this.branchCode,
    this.branchName,
    this.townshipCode,
    required this.role,
  });

  factory OfficerProfile.fromJson(Map<String, dynamic> json) {
    return OfficerProfile(
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      branchCode: json['branchCode']?.toString(),
      branchName: json['branchName']?.toString(),
      townshipCode: json['townshipCode']?.toString(),
      role: UserRole.fromCode(json['role']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'branchCode': branchCode,
      'branchName': branchName,
      'townshipCode': townshipCode,
      'role': role.code,
    };
  }

  @override
  List<Object?> get props => [userId, username, fullName, branchCode, branchName, townshipCode, role];
}
