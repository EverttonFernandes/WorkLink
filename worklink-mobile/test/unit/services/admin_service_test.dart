import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/admin_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;
  late AdminService adminService;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
    adminService = AdminService(httpClient: httpClient);
  });

  test(
      'GIVEN contratos administrativos WHEN carregar console THEN deve consumir endpoints esperados',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/admin/professionals'] = [
      {
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria',
        'cityIdentifier': 'city-1',
        'categoryIdentifier': 'category-1',
        'profileClassification': 'COMPLETE',
        'availabilityStatus': 'AVAILABLE_TODAY',
        'blocked': false,
      },
    ];
    httpClient.objectResponses['/api/v1/admin/metrics'] = {
      'professionalCount': 1,
      'blockedProfessionalCount': 0,
      'professionalReportCount': 2,
      'reviewAnalysisRequestCount': 1,
      'serviceCategoryCount': 3,
    };
    httpClient.objectResponses['/api/v1/admin/functional-metrics'] = {
      'searchCount': 10,
      'searchWithoutResultCount': 1,
      'contactCount': 4,
      'postContactFeedbackCount': 2,
      'reviewCount': 3,
      'anonymousReviewCount': 1,
      'professionalReportCount': 2,
      'reviewAnalysisRequestCount': 1,
      'rankingAlgorithmEnabled': false,
      'searchesByCategory': <Map<String, Object?>>[],
      'searchesByCity': <Map<String, Object?>>[],
      'contactsByProfessional': <Map<String, Object?>>[],
      'contactsByCategory': <Map<String, Object?>>[],
      'contactsByCity': <Map<String, Object?>>[],
      'professionalSummary': {
        'activeProfessionalCount': 1,
        'completeProfessionalCount': 1,
        'availableProfessionalCount': 1,
        'unavailableProfessionalCount': 0,
        'professionalsWithContactCount': 1,
      },
      'responsivenessSummary': {
        'respondedContactPercentage': 80.0,
        'noResponsePercentage': 20.0,
        'servicePerformedPercentage': 50.0,
        'postContactAnswerRatePercentage': 60.0,
      },
      'responsivenessSignals': <Map<String, Object?>>[],
      'reputationSummary': {
        'reviewCount': 3,
        'averageRating': 4.7,
        'anonymousReviewCount': 1,
        'professionalReportCount': 2,
        'reviewAnalysisRequestCount': 1,
      },
      'reputationSignals': <Map<String, Object?>>[],
    };

    // WHEN
    final professionals = await adminService.listAdministrativeProfessionals();
    final metrics = await adminService.loadAdministrativeMetrics();
    final functionalMetrics = await adminService.loadFunctionalMetrics();

    // THEN
    expect(professionals.single.professionalName, 'Maria');
    expect(metrics.serviceCategoryCount, 3);
    expect(functionalMetrics.searchCount, 10);
    expect(httpClient.requests[0].path, '/api/v1/admin/professionals');
    expect(httpClient.requests[1].path, '/api/v1/admin/metrics');
    expect(httpClient.requests[2].path, '/api/v1/admin/functional-metrics');
  });

  test(
      'GIVEN acoes administrativas WHEN operar console THEN deve enviar payloads corretos',
      () async {
    // GIVEN
    httpClient
        .objectResponses['/api/v1/admin/professionals/professional-1/block'] = {
      'professionalIdentifier': 'professional-1',
      'professionalName': 'Maria',
      'cityIdentifier': 'city-1',
      'categoryIdentifier': 'category-1',
      'profileClassification': 'COMPLETE',
      'availabilityStatus': 'AVAILABLE_TODAY',
      'blocked': true,
    };
    httpClient.objectResponses[
        '/api/v1/admin/professionals/professional-1/unblock'] = {
      'professionalIdentifier': 'professional-1',
      'professionalName': 'Maria',
      'cityIdentifier': 'city-1',
      'categoryIdentifier': 'category-1',
      'profileClassification': 'COMPLETE',
      'availabilityStatus': 'AVAILABLE_TODAY',
      'blocked': false,
    };
    httpClient.objectResponses['/api/v1/admin/reports/report-1/moderation'] = {
      'professionalReportIdentifier': 'report-1',
      'professionalIdentifier': 'professional-1',
      'reportReason': 'FRAUD',
      'seriousCase': false,
      'evidenceFileIdentifier': null,
      'moderationStatus': 'RESOLVED',
      'moderationDecision': 'KEEP_AS_IS',
      'moderationNotes': 'Revisado',
      'decidedAt': '2026-05-15T12:00:00Z',
      'createdAt': '2026-05-15T10:00:00Z',
    };
    httpClient.objectResponses[
        '/api/v1/admin/review-analysis-requests/analysis-1/moderation'] = {
      'reviewAnalysisRequestIdentifier': 'analysis-1',
      'professionalReviewIdentifier': 'review-1',
      'professionalIdentifier': 'professional-1',
      'requestedByProfessionalIdentifier': 'professional-1',
      'moderationStatus': 'ACTION_REQUIRED',
      'moderationDecision': 'HIDE_FROM_PUBLIC',
      'moderationNotes': null,
      'decidedAt': '2026-05-15T13:00:00Z',
      'createdAt': '2026-05-15T11:00:00Z',
    };

    // WHEN
    await adminService.blockProfessional('professional-1');
    await adminService.unblockProfessional('professional-1');
    await adminService.moderateProfessionalReport(
      professionalReportIdentifier: 'report-1',
      moderationStatus: 'RESOLVED',
      moderationDecision: 'KEEP_AS_IS',
      moderationNotes: 'Revisado',
    );
    await adminService.moderateReviewAnalysisRequest(
      reviewAnalysisRequestIdentifier: 'analysis-1',
      moderationStatus: 'ACTION_REQUIRED',
      moderationDecision: 'HIDE_FROM_PUBLIC',
    );
    await adminService.registerServiceCategory(' Eletricista ');

    // THEN
    expect(
      httpClient.requests[0].path,
      '/api/v1/admin/professionals/professional-1/block',
    );
    expect(
      httpClient.requests[1].path,
      '/api/v1/admin/professionals/professional-1/unblock',
    );
    expect(httpClient.requests[2].data['moderationDecision'], 'KEEP_AS_IS');
    expect(
      httpClient.requests[3].data['moderationDecision'],
      'HIDE_FROM_PUBLIC',
    );
    expect(httpClient.requests[4].data['categoryName'], 'Eletricista');
  });
}
