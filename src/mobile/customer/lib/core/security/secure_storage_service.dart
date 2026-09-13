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
  static const String _keyRefreshToken = 'bmf_customer_refresh_token';
  static const String _keyPinHash = 'bmf_customer_pin_hash';
  static const String _keyMemberNrc = 'bmf_customer_nrc';
  static const String _keyLastIdentifier = 'bmf_customer_last_identifier';
  static const String _keyLastFullName = 'bmf_customer_last_full_name';
  static const String _keyDeviceId = 'bmf_customer_device_id';
  static const String _keyLanguage = 'bmf_customer_lang';
  static const String _keyBiometricEnabled = 'bmf_customer_biometric_enabled';

  static const String _keyQuickActions = 'bmf_customer_quick_actions';

  Future<void> saveQuickActions(List<String> actions) => _storage.write(key: _keyQuickActions, value: actions.join(','));
  Future<List<String>?> getQuickActions() async {
    final val = await _storage.read(key: _keyQuickActions);
    if (val == null || val.isEmpty) return null;
    return val.split(',').where((s) => s.isNotEmpty).toList();
  }

  Future<void> saveDeviceId(String deviceId) => _storage.write(key: _keyDeviceId, value: deviceId);
  Future<String?> getDeviceId() => _storage.read(key: _keyDeviceId);

  Future<void> saveLastIdentifier(String identifier) => _storage.write(key: _keyLastIdentifier, value: identifier);
  Future<String?> getLastIdentifier() => _storage.read(key: _keyLastIdentifier);

  Future<void> saveLastFullName(String fullName) => _storage.write(key: _keyLastFullName, value: fullName);
  Future<String?> getLastFullName() => _storage.read(key: _keyLastFullName);

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    AppLogger.info('Saved customer authentication token securely.', tag: 'SecureStorage');
  }

  Future<String?> getAuthToken() => _storage.read(key: _keyToken);

  Future<void> saveAccessToken(String token) => saveAuthToken(token);
  Future<String?> getAccessToken() => getAuthToken();

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

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
    await _storage.delete(key: _keyRefreshToken);
    AppLogger.info('Cleared customer session tokens.', tag: 'SecureStorage');
  }

  Future<void> clearAllSession() async {
    await _storage.deleteAll();
    AppLogger.info('Cleared all secure customer data on full logout.', tag: 'SecureStorage');
  }

  Future<void> clearAuthTokens() => clearSession();
}

