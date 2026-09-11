import '../models/member_profile.dart';

/// Repository interface for borrower registration, SMS OTP verification, and PIN login.
abstract class CustomerAuthRepository {
  /// Sends an SMS OTP challenge to the member's registered phone number.
  Future<bool> requestRegistrationOtp({required String nrcFormatted, required String phone});

  /// Verifies the OTP code and initializes member session.
  Future<MemberProfile> verifyRegistrationOtp({
    required String nrcFormatted,
    required String phone,
    required String otpCode,
  });

  /// Configures a 6-digit security PIN and optional biometric lock.
  Future<void> setupSecurityPin({required String pin, required bool enableBiometric});

  /// Logs in an existing member with their 6-digit security PIN.
  Future<MemberProfile> loginWithPin({required String pin});

  /// Authenticates using biometrics.
  Future<MemberProfile> loginWithBiometric();

  /// Retrieves the active logged-in member profile.
  Future<MemberProfile?> getActiveProfile();

  /// Logs out the member and terminates local session.
  Future<void> logout();
}
