/// Constants applied across the entire BMF Agent Mobile Application.
class AppConstants {
  AppConstants._();

  static const String appName = 'BMF Agent';
  static const String appVersion = '1.0.0';
  static const String defaultCurrency = 'MMK';
  static const String defaultTimezone = 'Asia/Yangon'; // UTC+06:30

  // Database & Security Configuration
  static const String databaseName = 'bmf_agent_encrypted.db';
  static const String sqlCipherKeyStorageKey = 'bmf_sqlcipher_master_key_v1';
  static const String jwtAccessTokenKey = 'bmf_jwt_access_token';
  static const String jwtRefreshTokenKey = 'bmf_jwt_refresh_token';
  static const String loggedInUserKey = 'bmf_logged_in_user_profile';
  static const String selectedLanguageKey = 'bmf_selected_language_code';

  // Network & Timeout Configuration
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;
  static const int maxRetryAttempts = 3;
  static const int retryDelayBaseMs = 1000;

  // Synchronization Configuration
  static const int batchSyncChunkSize = 50;
  static const int syncIntervalMinutes = 15;
}
