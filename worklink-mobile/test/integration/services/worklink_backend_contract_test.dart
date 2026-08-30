import 'package:flutter/foundation.dart';
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

    // Wait for backend to be ready before proceeding
    await _waitForBackendReady(apiClient);

    final catalogService = CatalogService(httpClient: apiClient);
    final professionalService = ProfessionalService(httpClient: apiClient);

    // WHEN
    final categories = await catalogService.listServiceCategories();
    final cities = await catalogService.listServiceCities();
    final professionals = await professionalService.listProfessionals();

    // THEN
    expect(categories, isA<List<ServiceCategory>>());
    expect(cities, isA<List<ServiceCity>>());
    expect(professionals, isA<List<ProfessionalSummary>>());
  });
}

/// Waits for the backend API to be ready before running tests.
/// Retries up to [maxRetries] times with [delaySeconds] between attempts.
Future<void> _waitForBackendReady(
  ApiClient apiClient, {
  int maxRetries = 30,
  int delaySeconds = 2,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      debugPrint(
        'Waiting for backend to be ready... (attempt ${i + 1}/$maxRetries)',
      );
      await apiClient.getObject('/actuator/health/readiness');
      debugPrint('Backend is ready!');
      return;
    } catch (e) {
      if (i == maxRetries - 1) {
        throw Exception(
          'Backend API did not become ready after $maxRetries attempts. '
          'Last error: $e',
        );
      }
      await Future<void>.delayed(Duration(seconds: delaySeconds));
    }
  }
}
