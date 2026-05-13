import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/catalog_service.dart';
import 'package:worklink_mobile/services/models/report_model.dart';
import 'package:worklink_mobile/services/report_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
  });

  test(
      'GIVEN catalogo cadastrado WHEN listar categorias THEN deve usar contrato do backend',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/categories'] = [
      {
        'categoryIdentifier': 'category-1',
        'categoryName': 'Eletricista',
        'categorySlug': 'eletricista',
      },
    ];
    final catalogService = CatalogService(httpClient: httpClient);

    // WHEN
    final categories = await catalogService.listServiceCategories();

    // THEN
    expect(categories.single.categoryName, 'Eletricista');
    expect(httpClient.requests.single.path, '/api/v1/categories');
  });

  test(
      'GIVEN cidades cadastradas WHEN listar cidades THEN deve montar nome de exibicao',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/cities'] = [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
        'citySlug': 'canoas-rs',
      },
    ];
    final catalogService = CatalogService(httpClient: httpClient);

    // WHEN
    final cities = await catalogService.listServiceCities();

    // THEN
    expect(cities.single.displayName, 'Canoas - RS');
    expect(httpClient.requests.single.path, '/api/v1/cities');
  });

  test(
      'GIVEN denuncia preenchida WHEN registrar denuncia THEN deve chamar endpoint de moderacao',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professional-reports'] = {
      'professionalReportIdentifier': 'report-1',
      'professionalIdentifier': 'professional-1',
      'reportReason': 'FRAUD',
      'description': 'Perfil suspeito.',
      'evidenceFileIdentifier': null,
      'seriousCase': false,
      'authorityGuidance': '',
      'createdAt': '2026-05-13T10:00:00Z',
    };
    final reportService = ReportService(httpClient: httpClient);

    // WHEN
    final report = await reportService.registerProfessionalReport(
      const RegisterProfessionalReportRequest(
        professionalIdentifier: 'professional-1',
        reportReason: 'FRAUD',
        description: ' Perfil suspeito. ',
      ),
    );

    // THEN
    expect(report.professionalReportIdentifier, 'report-1');
    expect(httpClient.requests.single.path, '/api/v1/professional-reports');
    expect(httpClient.requests.single.data, {
      'professionalIdentifier': 'professional-1',
      'reportReason': 'FRAUD',
      'description': 'Perfil suspeito.',
      'evidenceFileIdentifier': null,
    });
  });
}
