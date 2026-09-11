import '../entities/officer_profile.dart';

/// Repository interface for Credit Officer authentication and session handling.
abstract class AuthRepository {
  Future<OfficerProfile> login({
    required String username,
    required String password,
    required String deviceId,
    required String platform,
    required String appVersion,
    String? pushToken,
  });

  Future<void> logout();

  Future<OfficerProfile?> getCachedProfile();

  Future<bool> hasValidSession();
}
