import 'api_client.dart';
import 'models/catalog_model.dart';

class CatalogService {
  const CatalogService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<List<ServiceCategory>> listServiceCategories() async {
    final response = await _httpClient.getList('/api/v1/categories');
    return response
        .map(
          (json) =>
              ServiceCategory.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  Future<List<ServiceCity>> listServiceCities() async {
    final response = await _httpClient.getList('/api/v1/cities');
    return response
        .map(
          (json) =>
              ServiceCity.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }
}
