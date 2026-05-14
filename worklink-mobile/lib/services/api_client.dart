import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'exceptions.dart';

abstract interface class WorkLinkHttpClient {
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, Object?> queryParameters = const {},
  });

  Future<List<dynamic>> getList(
    String path, {
    Map<String, Object?> queryParameters = const {},
  });

  Future<Map<String, dynamic>> postObject(
    String path, {
    Map<String, Object?> data = const {},
  });

  Future<Map<String, dynamic>> patchObject(
    String path, {
    Map<String, Object?> data = const {},
  });

  Future<void> postEmpty(
    String path, {
    Map<String, Object?> data = const {},
  });

  Future<void> deleteEmpty(
    String path, {
    Map<String, Object?> data = const {},
  });

  Future<Map<String, dynamic>> deleteObject(
    String path, {
    Map<String, Object?> data = const {},
  });

  void setBearerToken(String? token);

  void clearBearerToken();
}

class ApiClient implements WorkLinkHttpClient {
  ApiClient({
    String? baseUrl,
    String? bearerToken,
    bool enableLogging = false,
    Dio? dio,
  })  : _bearerToken = bearerToken,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ??
                    dotenv.env['API_BASE_URL'] ??
                    'http://localhost:8080',
                connectTimeout: _timeout,
                receiveTimeout: _timeout,
                sendTimeout: _timeout,
                validateStatus: (statusCode) =>
                    statusCode != null && statusCode < 500,
              ),
            ) {
    _configureInterceptors(enableLogging: enableLogging);
  }

  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  final Dio _dio;
  String? _bearerToken;

  @override
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, Object?> queryParameters = const {},
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: _sanitizeQueryParameters(queryParameters),
      ),
    );
    return _requireObjectResponse(response);
  }

  @override
  Future<List<dynamic>> getList(
    String path, {
    Map<String, Object?> queryParameters = const {},
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: _sanitizeQueryParameters(queryParameters),
      ),
    );
    return _requireListResponse(response);
  }

  @override
  Future<Map<String, dynamic>> postObject(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(path, data: _sanitizeBody(data)),
    );
    return _requireObjectResponse(response);
  }

  @override
  Future<Map<String, dynamic>> patchObject(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    final response = await _request(
      () => _dio.patch<dynamic>(path, data: _sanitizeBody(data)),
    );
    return _requireObjectResponse(response);
  }

  @override
  Future<void> postEmpty(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    await _request(() => _dio.post<dynamic>(path, data: _sanitizeBody(data)));
  }

  @override
  Future<void> deleteEmpty(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    await _request(() => _dio.delete<dynamic>(path, data: _sanitizeBody(data)));
  }

  @override
  Future<Map<String, dynamic>> deleteObject(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    final response = await _request(
      () => _dio.delete<dynamic>(path, data: _sanitizeBody(data)),
    );
    return _requireObjectResponse(response);
  }

  @override
  void setBearerToken(String? token) {
    _bearerToken = token?.trim().isEmpty == true ? null : token;
  }

  @override
  void clearBearerToken() {
    _bearerToken = null;
  }

  void _configureInterceptors({required bool enableLogging}) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _bearerToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final retryAttempt =
              error.requestOptions.extra['retryAttempt'] as int? ?? 0;
          if (_shouldRetry(error) && retryAttempt < _maxRetries) {
            final nextAttempt = retryAttempt + 1;
            error.requestOptions.extra['retryAttempt'] = nextAttempt;
            await Future<void>.delayed(
              Duration(milliseconds: 300 * nextAttempt),
            );
            try {
              handler.resolve(await _dio.fetch<dynamic>(error.requestOptions));
            } on DioException catch (retryError) {
              handler.next(retryError);
            }
            return;
          }
          handler.next(error);
        },
      ),
    );

    if (enableLogging && dotenv.env['LOG_REQUESTS'] == 'true') {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (message) => debugPrint('[WorkLink API] $message'),
        ),
      );
    }
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      _throwWhenStatusCodeRepresentsFailure(response);
      return response;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  void _throwWhenStatusCodeRepresentsFailure(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 400) {
      throw _mapStatusCodeToException(statusCode, response.data);
    }
  }

  Map<String, dynamic> _requireObjectResponse(Response<dynamic> response) {
    final data = response.data;
    if (data == null) {
      return {};
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const ApiException(
      message: 'Resposta inesperada recebida do servidor.',
    );
  }

  List<dynamic> _requireListResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is List) {
      return data;
    }
    throw const ApiException(
      message: 'Lista esperada nao foi recebida do servidor.',
    );
  }

  ApiException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Nao foi possivel conectar ao WorkLink agora.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCodeToException(
          error.response?.statusCode ?? 0,
          error.response?.data,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          message: 'Nao foi possivel concluir a requisicao.',
          originalError: error,
        );
    }
  }

  ApiException _mapStatusCodeToException(int statusCode, Object? responseData) {
    final message = _extractErrorMessage(responseData);
    return switch (statusCode) {
      400 || 422 => ValidationException(
          message: message,
          statusCode: statusCode,
        ),
      401 => AuthenticationException(
          message: message,
          statusCode: statusCode,
        ),
      403 => AuthorizationException(
          message: message,
          statusCode: statusCode,
        ),
      404 => NotFoundException(
          message: message,
          statusCode: statusCode,
        ),
      500 || 502 || 503 => ServerException(
          message: message,
          statusCode: statusCode,
        ),
      _ => ApiException(
          message: message,
          statusCode: statusCode,
        ),
    };
  }

  String _extractErrorMessage(Object? responseData) {
    if (responseData is Map) {
      final errorMessage = responseData['message'] ?? responseData['error'];
      if (errorMessage != null && errorMessage.toString().trim().isNotEmpty) {
        return errorMessage.toString();
      }
    }
    return 'Nao foi possivel concluir a operacao.';
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.response?.statusCode == 502 ||
        error.response?.statusCode == 503;
  }

  Map<String, Object?> _sanitizeQueryParameters(
    Map<String, Object?> queryParameters,
  ) {
    return Map<String, Object?>.fromEntries(
      queryParameters.entries.where((entry) => entry.value != null),
    );
  }

  Map<String, Object?> _sanitizeBody(Map<String, Object?> data) {
    return Map<String, Object?>.fromEntries(
      data.entries.where((entry) => entry.value != null),
    );
  }
}
