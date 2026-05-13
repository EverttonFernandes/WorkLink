// coverage:ignore-file

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final Object? originalError;

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

class AuthenticationException extends ApiException {
  const AuthenticationException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class AuthorizationException extends ApiException {
  const AuthorizationException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class NetworkException extends ApiException {
  const NetworkException({
    required super.message,
    super.originalError,
  });
}
