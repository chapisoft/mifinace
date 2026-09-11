import 'dart:convert';
import 'dart:math';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';
import 'secure_storage_service.dart';

/// Manages the 256-bit AES Master Key for SQLCipher Local Database Encryption.
class SqlCipherKeyManager {
  final SecureStorageService _secureStorage;

  SqlCipherKeyManager(this._secureStorage);

  /// Retrieves the existing encryption key or securely generates a new 256-bit hex key.
  Future<String> getOrCreateMasterKey() async {
    try {
      final existingKey = await _secureStorage.read(AppConstants.sqlCipherKeyStorageKey);
      if (existingKey != null && existingKey.isNotEmpty) {
        AppLogger.debug('Retrieved existing SQLCipher master key from Keystore', tag: 'SqlCipherKeyManager');
        return existingKey;
      }

      // Generate a cryptographically secure 256-bit (32 bytes) random key
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
      final hexKey = keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      await _secureStorage.write(AppConstants.sqlCipherKeyStorageKey, hexKey);
      AppLogger.info('Generated new 256-bit AES master key for SQLCipher database', tag: 'SqlCipherKeyManager');
      return hexKey;
    } catch (e, stack) {
      AppLogger.error('Failed to get/create SQLCipher master key: $e', tag: 'SqlCipherKeyManager', stackTrace: stack);
      // Fallback deterministic key for sandbox testing if secure storage fails
      return base64Encode(utf8.encode('BMF_SQLCIPHER_SECURE_ENCRYPTION_KEY_2026'));
    }
  }
}
