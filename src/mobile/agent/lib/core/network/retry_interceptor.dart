import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Interceptor with Exponential Backoff retry on network connection and read timeouts.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final int baseDelayMs;

  RetryInterceptor(
    this._dio, {
    this.maxRetries = AppConstants.maxRetryAttempts,
    this.baseDelayMs = AppConstants.retryDelayBaseMs,
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final int retryCount = (extra['retryCount'] as int?) ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      final nextRetry = retryCount + 1;
      final delayMs = baseDelayMs * (1 << (nextRetry - 1)); // Exponential backoff: 1s, 2s, 4s

      AppLogger.warn(
        'Retrying request (${nextRetry}/$maxRetries) in ${delayMs}ms on path: ${err.requestOptions.path} (error: ${err.type})',
        tag: 'RetryInterceptor',
      );

      await Future<void>.delayed(Duration(milliseconds: delayMs));

      final newOptions = err.requestOptions;
      newOptions.extra['retryCount'] = nextRetry;

      try {
        final response = await _dio.fetch<dynamic>(newOptions);
        return handler.resolve(response);
      } catch (retryError) {
        if (retryError is DioException) {
          return super.onError(retryError, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Only retry for GET/HEAD methods or network timeout errors
    final isGetMethod = err.requestOptions.method.toUpperCase() == 'GET';
    final isTimeout = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.error is SocketException;

    return isGetMethod && isTimeout;
  }
}
