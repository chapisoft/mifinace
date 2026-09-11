import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_logger.dart';

/// Interceptor attaching a unique UUIDv4 X-Idempotency-Key on non-GET HTTP methods.
class IdempotencyInterceptor extends Interceptor {
  final Uuid _uuid = const Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    if (method == 'POST' || method == 'PUT' || method == 'PATCH' || method == 'DELETE') {
      if (!options.headers.containsKey('X-Idempotency-Key') || options.headers['X-Idempotency-Key'] == null) {
        final idempotencyKey = _uuid.v4();
        options.headers['X-Idempotency-Key'] = idempotencyKey;
        AppLogger.debug('Attached X-Idempotency-Key: $idempotencyKey for ${options.method} ${options.path}',
            tag: 'IdempotencyInterceptor');
      }
    }
    handler.next(options);
  }
}
