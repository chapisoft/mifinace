/// Request payload for Credit Officer login.
class OfficerLoginRequest {
  final String username;
  final String password;
  final String deviceId;
  final String platform;
  final String appVersion;
  final String? pushToken;

  const OfficerLoginRequest({
    required this.username,
    required this.password,
    required this.deviceId,
    required this.platform,
    required this.appVersion,
    this.pushToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': appVersion,
      'pushToken': pushToken,
    };
  }
}
