import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../domain/models/member_profile.dart';
import '../../domain/repositories/customer_auth_repository.dart';

/// Implementation of [CustomerAuthRepository] handling OTP, PIN hashing, and session management.
class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final SecureStorageService _storage;
  final BiometricService _biometricService;

  MemberProfile? _cachedProfile;

  CustomerAuthRepositoryImpl({
    required SecureStorageService storage,
    required BiometricService biometricService,
  })  : _storage = storage,
        _biometricService = biometricService;

  String _hashPin(String pin) {
    final bytes = utf8.encode('BMF_SALT_$pin');
    return sha256.convert(bytes).toString();
  }

  @override
  Future<bool> requestRegistrationOtp({required String nrcFormatted, required String phone}) async {
    AppLogger.info('Requesting SMS OTP for NRC: $nrcFormatted, Phone: $phone', tag: 'AuthRepo');
    // Simulated SMS Gateway call
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<MemberProfile> verifyRegistrationOtp({
    required String nrcFormatted,
    required String phone,
    required String otpCode,
  }) async {
    AppLogger.info('Verifying SMS OTP for member: $nrcFormatted', tag: 'AuthRepo');
    if (otpCode.length != 6) {
      throw Exception('Invalid 6-digit OTP code.');
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final profile = MemberProfile(
      memberId: 'MEM-2026-0089',
      nrcFormatted: nrcFormatted,
      fullName: 'Daw Khin Khin Win',
      phone: phone,
      centerName: 'Taunggyi Central Center',
      groupName: 'Solidarity Group 01',
      totalSavingBalanceMmk: 250000.0,
      loyaltyPoints: 120,
      hasActiveLoans: true,
      isPinConfigured: false,
    );

    _cachedProfile = profile;
    await _storage.saveMemberNrc(nrcFormatted);
    await _storage.saveAuthToken('BMF_JWT_SESSION_${DateTime.now().millisecondsSinceEpoch}');
    return profile;
  }

  @override
  Future<void> setupSecurityPin({required String pin, required bool enableBiometric}) async {
    AppLogger.info('Configuring 6-digit security PIN for member', tag: 'AuthRepo');
    if (pin.length != 6) {
      throw Exception('Security PIN must be exactly 6 digits.');
    }

    final hash = _hashPin(pin);
    await _storage.savePinHash(hash);
    await _storage.setBiometricEnabled(enableBiometric);

    if (_cachedProfile != null) {
      _cachedProfile = MemberProfile(
        memberId: _cachedProfile!.memberId,
        nrcFormatted: _cachedProfile!.nrcFormatted,
        fullName: _cachedProfile!.fullName,
        phone: _cachedProfile!.phone,
        centerName: _cachedProfile!.centerName,
        groupName: _cachedProfile!.groupName,
        totalSavingBalanceMmk: _cachedProfile!.totalSavingBalanceMmk,
        loyaltyPoints: _cachedProfile!.loyaltyPoints,
        hasActiveLoans: _cachedProfile!.hasActiveLoans,
        isPinConfigured: true,
      );
    }
  }

  @override
  Future<MemberProfile> loginWithPin({required String pin}) async {
    AppLogger.info('Attempting login with 6-digit security PIN', tag: 'AuthRepo');
    final savedHash = await _storage.getPinHash();
    if (savedHash == null) {
      throw Exception('No security PIN configured on this device. Please register.');
    }

    final incomingHash = _hashPin(pin);
    if (savedHash != incomingHash) {
      throw Exception('Incorrect PIN. Please try again.');
    }

    final nrc = await _storage.getMemberNrc() ?? '12/DAGANA(N)123456';
    final profile = MemberProfile(
      memberId: 'MEM-2026-0089',
      nrcFormatted: nrc,
      fullName: 'Daw Khin Khin Win',
      phone: '09123456789',
      centerName: 'Taunggyi Central Center',
      groupName: 'Solidarity Group 01',
      totalSavingBalanceMmk: 250000.0,
      loyaltyPoints: 120,
      hasActiveLoans: true,
      isPinConfigured: true,
    );

    _cachedProfile = profile;
    await _storage.saveAuthToken('BMF_JWT_SESSION_${DateTime.now().millisecondsSinceEpoch}');
    return profile;
  }

  @override
  Future<MemberProfile> loginWithBiometric() async {
    AppLogger.info('Attempting login with Biometrics', tag: 'AuthRepo');
    final isEnabled = await _storage.isBiometricEnabled();
    if (!isEnabled) {
      throw Exception('Biometrics is not enabled for this account.');
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Scan fingerprint to access your BMF account',
    );

    if (!authenticated) {
      throw Exception('Biometric recognition canceled or failed.');
    }

    final nrc = await _storage.getMemberNrc() ?? '12/DAGANA(N)123456';
    final profile = MemberProfile(
      memberId: 'MEM-2026-0089',
      nrcFormatted: nrc,
      fullName: 'Daw Khin Khin Win',
      phone: '09123456789',
      centerName: 'Taunggyi Central Center',
      groupName: 'Solidarity Group 01',
      totalSavingBalanceMmk: 250000.0,
      loyaltyPoints: 120,
      hasActiveLoans: true,
      isPinConfigured: true,
    );

    _cachedProfile = profile;
    await _storage.saveAuthToken('BMF_JWT_SESSION_${DateTime.now().millisecondsSinceEpoch}');
    return profile;
  }

  @override
  Future<MemberProfile?> getActiveProfile() async {
    return _cachedProfile;
  }

  @override
  Future<void> logout() async {
    _cachedProfile = null;
    await _storage.clearSession();
    AppLogger.info('Customer logged out successfully.', tag: 'AuthRepo');
  }
}
