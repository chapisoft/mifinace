import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

/// Secure Encrypted Storage Service for sensitive borrower tokens and PIN hashes.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const String _keyToken = 'bmf_customer_auth_token';
  static const String _keyPinHash = 'bmf_customer_pin_hash';
  static const String _keyMemberNrc = 'bmf_customer_nrc';
  static const String _keyLanguage = 'bmf_customer_lang';
  static const String _keyBiometricEnabled = 'bmf_customer_biometric_enabled';

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    AppLogger.info('Saved customer authentication token securely.', tag: 'SecureStorage');
  }

  Future<String?> getAuthToken() => _storage.read(key: _keyToken);

  Future<void> savePinHash(String pinHash) async {
    await _storage.write(key: _keyPinHash, value: pinHash);
    AppLogger.info('Saved 6-digit security PIN hash securely.', tag: 'SecureStorage');
  }

  Future<String?> getPinHash() => _storage.read(key: _keyPinHash);

  Future<bool> hasPinSet() async {
    final pin = await getPinHash();
    return pin != null && pin.isNotEmpty;
  }

  Future<void> saveMemberNrc(String nrc) => _storage.write(key: _keyMemberNrc, value: nrc);

  Future<String?> getMemberNrc() => _storage.read(key: _keyMemberNrc);

  Future<void> saveLanguage(String langCode) => _storage.write(key: _keyLanguage, value: langCode);

  Future<String?> getLanguage() => _storage.read(key: _keyLanguage);

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _keyBiometricEnabled, value: enabled.toString());

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    AppLogger.info('Cleared customer session tokens.', tag: 'SecureStorage');
  }
}
