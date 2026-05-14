import 'package:worklink_mobile/services/api_client.dart';

class RecordedHttpRequest {
  const RecordedHttpRequest({
    required this.method,
    required this.path,
    this.queryParameters = const {},
    this.data = const {},
  });

  final String method;
  final String path;
  final Map<String, Object?> queryParameters;
  final Map<String, Object?> data;
}

class FakeWorkLinkHttpClient implements WorkLinkHttpClient {
  final List<RecordedHttpRequest> requests = [];
  final Map<String, Map<String, dynamic>> objectResponses = {};
  final Map<String, List<dynamic>> listResponses = {};
  final List<String?> bearerTokens = [];

  @override
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, Object?> queryParameters = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(
        method: 'GET',
        path: path,
        queryParameters: queryParameters,
      ),
    );
    return objectResponses[path] ?? {};
  }

  @override
  Future<List<dynamic>> getList(
    String path, {
    Map<String, Object?> queryParameters = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(
        method: 'GET',
        path: path,
        queryParameters: queryParameters,
      ),
    );
    return listResponses[path] ?? [];
  }

  @override
  Future<Map<String, dynamic>> postObject(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(method: 'POST', path: path, data: data),
    );
    return objectResponses[path] ?? {};
  }

  @override
  Future<Map<String, dynamic>> patchObject(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(method: 'PATCH', path: path, data: data),
    );
    return objectResponses[path] ?? {};
  }

  @override
  Future<void> postEmpty(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(method: 'POST', path: path, data: data),
    );
  }

  @override
  Future<void> deleteEmpty(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(method: 'DELETE', path: path, data: data),
    );
  }

  @override
  Future<Map<String, dynamic>> deleteObject(
    String path, {
    Map<String, Object?> data = const {},
  }) async {
    requests.add(
      RecordedHttpRequest(method: 'DELETE', path: path, data: data),
    );
    return objectResponses[path] ?? {};
  }

  @override
  void setBearerToken(String? token) {
    bearerTokens.add(token);
  }

  @override
  void clearBearerToken() {
    bearerTokens.add(null);
  }
}
