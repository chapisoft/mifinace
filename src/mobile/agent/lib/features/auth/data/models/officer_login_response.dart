import '../../domain/entities/officer_profile.dart';

/// Response payload from Credit Officer login API.
class OfficerLoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final OfficerProfile profile;

  const OfficerLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.profile,
  });

  factory OfficerLoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userMap = data['user'] as Map<String, dynamic>? ?? data;

    return OfficerLoginResponse(
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 900,
      profile: OfficerProfile.fromJson(userMap),
    );
  }
}
