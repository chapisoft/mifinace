/// Base class for application and network exceptions.
class AppException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;
  final Map<String, dynamic>? details;

  AppException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AppException(code: $errorCode, status: $statusCode, message: $message)';
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.statusCode, super.details});
}

class ServerException extends AppException {
  ServerException({required super.message, super.errorCode, super.statusCode, super.details});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'Session expired. Please log in again.'})
      : super(errorCode: 'ERR_UNAUTHORIZED', statusCode: 401);
}

class ConflictException extends AppException {
  ConflictException({required super.message, super.errorCode = 'ERR_CONFLICT'})
      : super(statusCode: 409);
}
