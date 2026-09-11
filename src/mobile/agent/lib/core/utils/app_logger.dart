import 'dart:developer' as developer;

/// Structured Technical Logger in English for BMF Mobile Application.
/// Strictly enforces English technical logs with level, tag, and trace contexts.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', tag, message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String tag = 'App', Object? error}) {
    _log('INFO', tag, message, error: error);
  }

  static void warn(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) {
    _log('WARN', tag, message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) {
    _log('ERROR', tag, message, error: error, stackTrace: stackTrace);
  }

  // Convenient aliases matching standard logging convention
  static void d(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) =>
      AppLogger.debug(message, tag: tag, error: error, stackTrace: stackTrace);

  static void i(String message, {String tag = 'App', Object? error}) =>
      AppLogger.info(message, tag: tag, error: error);

  static void w(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) =>
      AppLogger.warn(message, tag: tag, error: error, stackTrace: stackTrace);

  static void e(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) =>
      AppLogger.error(message, tag: tag, error: error, stackTrace: stackTrace);

  static void _log(String level, String tag, String message, {Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final formattedMessage = '[$timestamp] [$level] [$tag] $message';
    developer.log(
      formattedMessage,
      name: tag,
      time: DateTime.now(),
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _levelToInt(String level) {
    switch (level) {
      case 'DEBUG':
        return 500;
      case 'INFO':
        return 800;
      case 'WARN':
        return 900;
      case 'ERROR':
        return 1000;
      default:
        return 800;
    }
  }
}
