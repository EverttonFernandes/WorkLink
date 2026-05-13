import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/api_client.dart';
import 'package:worklink_mobile/services/catalog_service.dart';
import 'package:worklink_mobile/services/models/catalog_model.dart';
import 'package:worklink_mobile/services/models/professional_model.dart';
import 'package:worklink_mobile/services/professional_service.dart';

void main() {
  test(
      'GIVEN backend real no Docker WHEN consultar contratos publicos THEN deve responder listas validas',
      () async {
    // GIVEN
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://worklink-api:8080',
    );
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final catalogService = CatalogService(httpClient: apiClient);
    final professionalService = ProfessionalService(httpClient: apiClient);

    // WHEN
    final categories = await catalogService.listServiceCategories();
    final cities = await catalogService.listServiceCities();
    final professionals = await professionalService.listProfessionals();

    // THEN
    expect(categories, isA<List<ServiceCategory>>());
    expect(cities, isA<List<ServiceCity>>());
    expect(professionals, isA<List<Professional>>());
  });
}
