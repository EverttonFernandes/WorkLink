import 'api_client.dart';
import 'models/discovery_model.dart';

class DiscoveryService {
  const DiscoveryService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<DiscoveryResult> discoverProfessionals(
    DiscoveryRequest request,
  ) async {
    final response = await _httpClient.getList(
      '/api/v1/professionals',
      queryParameters: request.toQueryParameters(),
    );
    return DiscoveryResult.fromJsonList(response);
  }
}
