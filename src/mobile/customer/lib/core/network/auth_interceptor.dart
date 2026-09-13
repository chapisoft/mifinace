import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../security/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Interceptor attaching JWT Bearer Token and handling 401 token refresh flows for Customer App.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isPublicEndpoint(err.requestOptions.path)) {
      AppLogger.warn('Received 401 Unauthorized on path: ${err.requestOptions.path}. Attempting token refresh...',
          tag: 'AuthInterceptor');

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          AppLogger.warn('Refresh token is absent, clearing credentials', tag: 'AuthInterceptor');
          await _secureStorage.clearAuthTokens();
          return handler.next(err);
        }

        final refreshResponse = await _dio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
          final newAccessToken = refreshResponse.data['data']?['accessToken'] ?? refreshResponse.data['accessToken'];
          final newRefreshToken = refreshResponse.data['data']?['refreshToken'] ?? refreshResponse.data['refreshToken'];

          if (newAccessToken != null) {
            await _secureStorage.saveAccessToken(newAccessToken.toString());
            if (newRefreshToken != null) {
              await _secureStorage.saveRefreshToken(newRefreshToken.toString());
            }

            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final cloneResponse = await _dio.fetch(originalOptions);
            return handler.resolve(cloneResponse);
          }
        }
      } catch (refreshErr) {
        AppLogger.error('Failed to refresh token: $refreshErr. Clearing session.', tag: 'AuthInterceptor');
        await _secureStorage.clearAuthTokens();
      }
    }

    return handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path.contains('/auth/customer-login') ||
        path.contains('/auth/refresh-token') ||
        path.contains('/health');
  }
}
