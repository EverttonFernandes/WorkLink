import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/api_client.dart';
import 'package:worklink_mobile/services/exceptions.dart';

void main() {
  test(
      'GIVEN resposta objeto WHEN executar GET THEN deve retornar JSON e enviar Bearer',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 200, body: {'name': 'WorkLink'}),
      ],
    );
    final apiClient = createApiClient(adapter);
    apiClient.setBearerToken('access-token');

    // WHEN
    final response = await apiClient.getObject(
      '/api/v1/example',
      queryParameters: {'cityIdentifier': 'city-1', 'empty': null},
    );

    // THEN
    expect(response, {'name': 'WorkLink'});
    expect(adapter.requests.single.path, '/api/v1/example');
    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer access-token',
    );
    expect(
      adapter.requests.single.queryParameters,
      {'cityIdentifier': 'city-1'},
    );
  });

  test('GIVEN resposta lista WHEN executar GET list THEN deve retornar itens',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(
          statusCode: 200,
          body: [
            {'professionalIdentifier': 'professional-1'},
          ],
        ),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    final response = await apiClient.getList('/api/v1/professionals');

    // THEN
    expect(response.single, {'professionalIdentifier': 'professional-1'});
  });

  test(
      'GIVEN corpo com nulos WHEN executar POST THEN deve enviar somente valores preenchidos',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 201, body: {'id': 'created'}),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    final response = await apiClient.postObject(
      '/api/v1/professionals',
      data: {'name': 'Maria', 'ignored': null},
    );

    // THEN
    expect(response, {'id': 'created'});
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.data, {'name': 'Maria'});
  });

  test(
      'GIVEN corpo parcial WHEN executar PATCH THEN deve enviar body sanitizado',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 200, body: {'id': 'updated'}),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    final response = await apiClient.patchObject(
      '/api/v1/professionals/professional-1/profile',
      data: {'usefulLink': 'https://example.com', 'ignored': null},
    );

    // THEN
    expect(response, {'id': 'updated'});
    expect(adapter.requests.single.method, 'PATCH');
    expect(adapter.requests.single.data, {'usefulLink': 'https://example.com'});
  });

  test(
      'GIVEN resposta objeto WHEN executar DELETE object THEN deve retornar JSON do backend',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 200, body: {'removed': true}),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    final response = await apiClient.deleteObject(
      '/api/v1/customers/me/saved-professionals/professional-1',
    );

    // THEN
    expect(response, {'removed': true});
    expect(adapter.requests.single.method, 'DELETE');
  });

  test(
      'GIVEN requisicao sem resposta WHEN executar DELETE empty THEN deve concluir sem erro',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 204, body: null),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    await apiClient.deleteEmpty('/api/v1/example');

    // THEN
    expect(adapter.requests.single.method, 'DELETE');
  });

  test(
      'GIVEN logout WHEN limpar Bearer THEN request seguinte nao deve enviar token',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 204, body: null),
      ],
    );
    final apiClient = createApiClient(adapter);
    apiClient.setBearerToken('access-token');
    apiClient.clearBearerToken();

    // WHEN
    await apiClient.postEmpty('/api/v1/authentication/session/revoke');

    // THEN
    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test(
      'GIVEN falha transiente WHEN servidor recuperar THEN deve repetir request',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(
          statusCode: 503,
          body: {'message': 'Indisponivel'},
        ),
        const FakeDioResponse(statusCode: 200, body: {'status': 'ok'}),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    final response = await apiClient.getObject('/api/v1/health');

    // THEN
    expect(response, {'status': 'ok'});
    expect(adapter.requests, hasLength(2));
  });

  test(
      'GIVEN resposta 401 WHEN executar request THEN deve mapear erro de autenticacao',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(
          statusCode: 401,
          body: {'message': 'Token invalido'},
        ),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN + THEN
    expect(
      () => apiClient.getObject('/api/v1/protegido'),
      throwsA(isA<AuthenticationException>()),
    );
  });

  test(
      'GIVEN respostas HTTP de falha WHEN executar request THEN deve mapear excecoes especificas',
      () async {
    // GIVEN
    final cases = <int>[400, 403, 404, 500, 418];

    for (final statusCode in cases) {
      final adapter = FakeDioAdapter(
        responses: [
          FakeDioResponse(
            statusCode: statusCode,
            body: {'message': 'Falha $statusCode'},
          ),
        ],
      );
      final apiClient = createApiClient(adapter);

      // WHEN + THEN
      expect(
        () => apiClient.getObject('/api/v1/falha'),
        throwsA(isA<ApiException>()),
      );
    }
  });

  test(
      'GIVEN formato inesperado WHEN esperar objeto THEN deve falhar com ApiException',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 200, body: ['nao-e-objeto']),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN + THEN
    expect(
      () => apiClient.getObject('/api/v1/example'),
      throwsA(isA<ApiException>()),
    );
  });

  test(
      'GIVEN formato inesperado WHEN esperar lista THEN deve falhar com ApiException',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 200, body: {'nao': 'lista'}),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN + THEN
    expect(
      () => apiClient.getList('/api/v1/example'),
      throwsA(isA<ApiException>()),
    );
  });

  test('GIVEN resposta vazia WHEN esperar objeto THEN deve retornar mapa vazio',
      () async {
    // GIVEN
    final adapter = FakeDioAdapter(
      responses: [
        const FakeDioResponse(statusCode: 204, body: null),
      ],
    );
    final apiClient = createApiClient(adapter);

    // WHEN
    final response = await apiClient.getObject('/api/v1/empty');

    // THEN
    expect(response, isEmpty);
  });

  test(
      'GIVEN erro de conexao WHEN executar request THEN deve mapear NetworkException',
      () async {
    // GIVEN
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
    final adapter = FakeDioAdapter(
      responses: [
        connectionError(),
        connectionError(),
        connectionError(),
        connectionError(),
      ],
    );
    dio.httpClientAdapter = adapter;
    final apiClient = ApiClient(dio: dio);

    // WHEN + THEN
    expect(
      () => apiClient.getObject('/api/v1/offline'),
      throwsA(isA<NetworkException>()),
    );
  });
}

DioException connectionError() {
  return DioException.connectionError(
    requestOptions: RequestOptions(path: '/api/v1/offline'),
    reason: 'offline',
  );
}

ApiClient createApiClient(FakeDioAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      validateStatus: (statusCode) => statusCode != null && statusCode < 500,
    ),
  )..httpClientAdapter = adapter;
  return ApiClient(dio: dio);
}

class FakeDioAdapter implements HttpClientAdapter {
  FakeDioAdapter({required this.responses});

  final List<Object> responses;
  final List<FakeDioRequest> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      FakeDioRequest(
        method: options.method,
        path: options.path,
        headers: Map<String, Object?>.from(options.headers),
        queryParameters: Map<String, Object?>.from(options.queryParameters),
        data: Map<String, Object?>.from(options.data as Map? ?? const {}),
      ),
    );
    final response = responses.removeAt(0);
    if (response is DioException) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    response as FakeDioResponse;
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeDioRequest {
  const FakeDioRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.queryParameters,
    required this.data,
  });

  final String method;
  final String path;
  final Map<String, Object?> headers;
  final Map<String, Object?> queryParameters;
  final Map<String, Object?> data;
}

class FakeDioResponse {
  const FakeDioResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final Object? body;
}
