import 'dart:developer' as developer;

/// Structured technical logging utility ensuring Zero Vietnamese in Technical Logs.
class AppLogger {
  AppLogger._();

  static void info(String message, {String tag = 'CustomerApp', Object? error, StackTrace? stackTrace}) {
    developer.log('[INFO] $message', name: tag, error: error, stackTrace: stackTrace);
  }

  static void warn(String message, {String tag = 'CustomerApp', Object? error, StackTrace? stackTrace}) {
    developer.log('[WARN] $message', name: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String tag = 'CustomerApp', Object? error, StackTrace? stackTrace}) {
    developer.log('[ERROR] $message', name: tag, error: error, stackTrace: stackTrace);
  }

  static void debug(String message, {String tag = 'CustomerApp'}) {
    developer.log('[DEBUG] $message', name: tag);
  }
}
