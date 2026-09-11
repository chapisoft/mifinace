import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../security/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'auth_interceptor.dart';
import 'idempotency_interceptor.dart';
import 'retry_interceptor.dart';

/// Central HTTP API Client for BMF Mobile BFF Gateway communication.
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
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'ANDROID',
          'X-Client-App-Version': AppConstants.appVersion,
        },
      ),
    );

    // Register Interceptors in order
    dio.interceptors.addAll([
      IdempotencyInterceptor(),
      AuthInterceptor(secureStorage, dio),
      RetryInterceptor(dio),
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    AppLogger.error('Dio error on path: ${e.requestOptions.path}, type: ${e.type}',
        tag: 'ApiClient', error: e.error);

    if (e.response != null && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      final message = data['title'] ?? data['message'] ?? data['detail'] ?? 'Server error occurred.';
      final errorCode = data['code']?.toString();
      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        return UnauthorizedException(message: message.toString());
      }
      if (statusCode == 409) {
        return ConflictException(message: message.toString(), errorCode: errorCode ?? 'ERR_CONFLICT');
      }

      return ServerException(
        message: message.toString(),
        errorCode: errorCode,
        statusCode: statusCode,
        details: data,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Network connection error. Please check your internet connectivity.',
        statusCode: e.response?.statusCode,
      );
    }

    return AppException(
      message: e.message ?? 'An unexpected network error occurred.',
      statusCode: e.response?.statusCode,
    );
  }
}
