import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Secure Storage Service backed by Android Keystore and iOS Keychain.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.jwtAccessTokenKey, value: token);
    AppLogger.debug('Saved JWT Access Token into Secure Storage', tag: 'SecureStorage');
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.jwtAccessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.jwtRefreshTokenKey, value: token);
    AppLogger.debug('Saved JWT Refresh Token into Secure Storage', tag: 'SecureStorage');
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.jwtRefreshTokenKey);
  }

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: AppConstants.jwtAccessTokenKey);
    await _storage.delete(key: AppConstants.jwtRefreshTokenKey);
    await _storage.delete(key: AppConstants.loggedInUserKey);
    AppLogger.info('Cleared authentication tokens from Secure Storage', tag: 'SecureStorage');
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
    AppLogger.warn('Deleted all keys from Secure Storage', tag: 'SecureStorage');
  }
}
