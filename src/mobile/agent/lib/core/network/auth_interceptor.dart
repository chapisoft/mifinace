import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../security/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Interceptor attaching JWT Bearer Token and handling 401 token refresh flows.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Exclude public endpoints (Login, Refresh, etc.)
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

        // Call Refresh Token API
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

            // Retry the original failed request with new access token
            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            AppLogger.info('Token refreshed successfully. Retrying original request: ${originalOptions.path}',
                tag: 'AuthInterceptor');

            final retryResponse = await _dio.fetch<dynamic>(originalOptions);
            return handler.resolve(retryResponse);
          }
        }
      } catch (refreshErr) {
        AppLogger.error('Failed to refresh token: $refreshErr. Logging out user.', tag: 'AuthInterceptor');
        await _secureStorage.clearAuthTokens();
      }
    }

    return handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path.contains(ApiEndpoints.loginOfficer) || path.contains(ApiEndpoints.refreshToken);
  }
}
