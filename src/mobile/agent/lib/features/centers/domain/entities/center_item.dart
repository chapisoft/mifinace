import 'package:equatable/equatable.dart';

/// Entity representing a Center (Cụm sinh hoạt buôn làng).
class CenterItem extends Equatable {
  final String centerId;
  final String centerCode;
  final String centerName;
  final String meetingDay;
  final String meetingTime;
  final String townshipCode;
  final String officerId;

  const CenterItem({
    required this.centerId,
    required this.centerCode,
    required this.centerName,
    required this.meetingDay,
    required this.meetingTime,
    required this.townshipCode,
    required this.officerId,
  });

  factory CenterItem.fromJson(Map<String, dynamic> json) {
    return CenterItem(
      centerId: json['centerId']?.toString() ?? json['id']?.toString() ?? '',
      centerCode: json['centerCode']?.toString() ?? '',
      centerName: json['centerName']?.toString() ?? '',
      meetingDay: json['meetingDay']?.toString() ?? '',
      meetingTime: json['meetingTime']?.toString() ?? '',
      townshipCode: json['townshipCode']?.toString() ?? '',
      officerId: json['officerId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'centerCode': centerCode,
      'centerName': centerName,
      'meetingDay': meetingDay,
      'meetingTime': meetingTime,
      'townshipCode': townshipCode,
      'officerId': officerId,
    };
  }

  @override
  List<Object?> get props => [centerId, centerCode, centerName, meetingDay, meetingTime, townshipCode, officerId];
}
