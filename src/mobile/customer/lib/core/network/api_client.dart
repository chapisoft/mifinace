import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../security/secure_storage_service.dart';
import '../security/ssl_pinning_client.dart';
import '../utils/app_logger.dart';
import 'auth_interceptor.dart';

/// Central HTTP API Client for BMF Mobile BFF Gateway communication for Customer App.
class ApiClient {
  late final Dio dio;
  final SecureStorageService secureStorage;

  ApiClient({
    required this.secureStorage,
    String? baseUrl,
  }) {
    final effectiveBaseUrl = baseUrl ?? ApiEndpoints.defaultBaseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'ANDROID',
        },
      ),
    );

    // Apply strict SSL Pinning
    SslPinningClient.applyCertificatePinning(dio);

    // Register Interceptors
    dio.interceptors.addAll([
      AuthInterceptor(secureStorage, dio),
      LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        logPrint: (obj) => AppLogger.debug(obj.toString(), tag: 'DioHttp'),
      ),
    ]);
  }

  /// Perform a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      AppLogger.info('GET $path', tag: 'ApiClient');
      return await dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      AppLogger.error('GET $path failed: ${e.message}', tag: 'ApiClient');
      rethrow;
    }
  }

  /// Perform a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      AppLogger.info('POST $path', tag: 'ApiClient');
      return await dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      AppLogger.error('POST $path failed: ${e.message}', tag: 'ApiClient');
      rethrow;
    }
  }

  /// Perform a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      AppLogger.info('PUT $path', tag: 'ApiClient');
      return await dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      AppLogger.error('PUT $path failed: ${e.message}', tag: 'ApiClient');
      rethrow;
    }
  }

  /// Perform a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      AppLogger.info('DELETE $path', tag: 'ApiClient');
      return await dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      AppLogger.error('DELETE $path failed: ${e.message}', tag: 'ApiClient');
      rethrow;
    }
  }
}
