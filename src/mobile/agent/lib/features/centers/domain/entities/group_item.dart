import 'package:equatable/equatable.dart';

/// Entity representing a Group (Tổ vay vốn) within a Center.
class GroupItem extends Equatable {
  final String groupId;
  final String groupCode;
  final String groupName;
  final String centerCode;
  final String? leaderName;
  final String? leaderPhone;
  final int memberCount;

  const GroupItem({
    required this.groupId,
    required this.groupCode,
    required this.groupName,
    required this.centerCode,
    this.leaderName,
    this.leaderPhone,
    required this.memberCount,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) {
    return GroupItem(
      groupId: json['groupId']?.toString() ?? json['id']?.toString() ?? '',
      groupCode: json['groupCode']?.toString() ?? '',
      groupName: json['groupName']?.toString() ?? '',
      centerCode: json['centerCode']?.toString() ?? '',
      leaderName: json['leaderName']?.toString(),
      leaderPhone: json['leaderPhone']?.toString(),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupCode': groupCode,
      'groupName': groupName,
      'centerCode': centerCode,
      'leaderName': leaderName,
      'leaderPhone': leaderPhone,
      'memberCount': memberCount,
    };
  }

  @override
  List<Object?> get props => [groupId, groupCode, groupName, centerCode, leaderName, leaderPhone, memberCount];
}
