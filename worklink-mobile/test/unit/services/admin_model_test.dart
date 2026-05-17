import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/models/admin_model.dart';

void main() {
  test(
      'GIVEN contratos administrativos completos WHEN desserializar THEN deve mapear todos os modelos',
      () {
    // GIVEN
    final professional = AdministrativeProfessionalModel.fromJson({
      'professionalIdentifier': 'professional-1',
      'professionalName': 'Maria',
      'cityIdentifier': 'city-1',
      'categoryIdentifier': 'category-1',
      'profileClassification': 'COMPLETE',
      'availabilityStatus': 'AVAILABLE_TODAY',
      'blocked': true,
    });
    final report = AdministrativeProfessionalReportModel.fromJson({
      'professionalReportIdentifier': 'report-1',
      'professionalIdentifier': 'professional-1',
      'reportReason': 'FRAUD',
      'seriousCase': true,
      'evidenceFileIdentifier': 'file-1',
      'moderationStatus': 'RESOLVED',
      'moderationDecision': 'KEEP_AS_IS',
      'moderationNotes': 'Revisado',
      'decidedAt': '2026-05-17T10:05:00Z',
      'createdAt': '2026-05-17T10:00:00Z',
    });
    final reviewAnalysis = AdministrativeReviewAnalysisRequestModel.fromJson({
      'reviewAnalysisRequestIdentifier': 'analysis-1',
      'professionalReviewIdentifier': 'review-1',
      'professionalIdentifier': 'professional-1',
      'requestedByProfessionalIdentifier': 'professional-1',
      'moderationStatus': 'ACTION_REQUIRED',
      'moderationDecision': 'HIDE_FROM_PUBLIC',
      'moderationNotes': 'Ocultada',
      'decidedAt': '2026-05-17T11:05:00Z',
      'createdAt': '2026-05-17T11:00:00Z',
    });
    final metrics = AdministrativeMetricsModel.fromJson({
      'professionalCount': '3',
      'blockedProfessionalCount': 1,
      'professionalReportCount': '2',
      'reviewAnalysisRequestCount': 4,
      'serviceCategoryCount': '5',
    });
    final functionalMetrics = FunctionalMetricsModel.fromJson({
      'searchCount': '10',
      'searchWithoutResultCount': 2,
      'contactCount': '6',
      'postContactFeedbackCount': 3,
      'reviewCount': '4',
      'anonymousReviewCount': 1,
      'professionalReportCount': 2,
      'reviewAnalysisRequestCount': 1,
      'rankingAlgorithmEnabled': true,
      'searchesByCategory': [
        {'metricIdentifier': 'category-1', 'contactCount': '7'},
      ],
      'searchesByCity': [
        {'metricIdentifier': 'city-1', 'contactCount': 6},
      ],
      'contactsByProfessional': [
        {'metricIdentifier': 'professional-1', 'contactCount': 3},
      ],
      'contactsByCategory': [
        {'metricIdentifier': 'category-1', 'contactCount': 3},
      ],
      'contactsByCity': [
        {'metricIdentifier': 'city-1', 'contactCount': 3},
      ],
      'professionalSummary': {
        'activeProfessionalCount': '3',
        'completeProfessionalCount': 2,
        'availableProfessionalCount': '2',
        'unavailableProfessionalCount': 1,
        'professionalsWithContactCount': '3',
      },
      'responsivenessSummary': {
        'respondedContactPercentage': '80.5',
        'noResponsePercentage': 19,
        'servicePerformedPercentage': 50.0,
        'postContactAnswerRatePercentage': '60.0',
      },
      'responsivenessSignals': [
        {'contactResponsiveness': 'FAST_RESPONSE', 'feedbackCount': '4'},
      ],
      'reputationSummary': {
        'reviewCount': '4',
        'averageRating': '4.8',
        'anonymousReviewCount': 1,
        'professionalReportCount': 2,
        'reviewAnalysisRequestCount': '1',
      },
      'reputationSignals': [
        {
          'professionalIdentifier': 'professional-1',
          'averageRating': '4.8',
          'reviewCount': '4',
        },
      ],
    });

    // WHEN / THEN
    expect(professional.blocked, isTrue);
    expect(report.evidenceFileIdentifier, 'file-1');
    expect(report.decidedAt, DateTime.parse('2026-05-17T10:05:00Z'));
    expect(reviewAnalysis.moderationDecision, 'HIDE_FROM_PUBLIC');
    expect(metrics.serviceCategoryCount, 5);
    expect(functionalMetrics.rankingAlgorithmEnabled, isTrue);
    expect(functionalMetrics.searchesByCategory.single.contactCount, 7);
    expect(functionalMetrics.searchesByCity.single.metricIdentifier, 'city-1');
    expect(
      functionalMetrics.contactsByProfessional.single.metricIdentifier,
      'professional-1',
    );
    expect(functionalMetrics.contactsByCategory.single.contactCount, 3);
    expect(functionalMetrics.contactsByCity.single.contactCount, 3);
    expect(functionalMetrics.professionalSummary.activeProfessionalCount, 3);
    expect(
      functionalMetrics.responsivenessSummary.respondedContactPercentage,
      80.5,
    );
    expect(
      functionalMetrics.responsivenessSignals.single.contactResponsiveness,
      'FAST_RESPONSE',
    );
    expect(functionalMetrics.reputationSummary.averageRating, 4.8);
    expect(
      functionalMetrics.reputationSignals.single.professionalIdentifier,
      'professional-1',
    );
  });

  test(
      'GIVEN contratos administrativos incompletos WHEN desserializar THEN deve aplicar fallbacks conservadores',
      () {
    // GIVEN
    final professional = AdministrativeProfessionalModel.fromJson({});
    final report = AdministrativeProfessionalReportModel.fromJson({
      'createdAt': '2026-05-17T10:00:00Z',
    });
    final reviewAnalysis = AdministrativeReviewAnalysisRequestModel.fromJson({
      'createdAt': '2026-05-17T11:00:00Z',
    });
    final metrics = AdministrativeMetricsModel.fromJson({});
    final functionalMetrics = FunctionalMetricsModel.fromJson({});

    // WHEN / THEN
    expect(professional.professionalName, isEmpty);
    expect(report.reportReason, isEmpty);
    expect(report.decidedAt, isNull);
    expect(reviewAnalysis.moderationNotes, isNull);
    expect(metrics.professionalCount, 0);
    expect(functionalMetrics.searchCount, 0);
    expect(functionalMetrics.searchesByCategory, isEmpty);
    expect(functionalMetrics.professionalSummary.availableProfessionalCount, 0);
    expect(
      functionalMetrics.responsivenessSummary.postContactAnswerRatePercentage,
      0,
    );
    expect(functionalMetrics.reputationSignals, isEmpty);
  });
}
