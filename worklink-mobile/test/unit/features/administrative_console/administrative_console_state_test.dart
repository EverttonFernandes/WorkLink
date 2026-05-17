import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_state.dart';

void main() {
  test(
      'GIVEN estado administrativo vazio WHEN consultar conteudo THEN deve indicar ausencia de dados',
      () {
    // GIVEN
    const state = AdministrativeConsoleState.loading();

    // WHEN / THEN
    expect(state.loading, isTrue);
    expect(state.hasContent, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.statusMessage, isNull);
  });

  test(
      'GIVEN estado administrativo preenchido WHEN copiar com novos campos THEN deve preservar dados nao alterados',
      () {
    // GIVEN
    const originalState = AdministrativeConsoleState(
      errorMessage: 'Falha anterior',
      statusMessage: 'Console carregado.',
      professionals: [
        AdministrativeProfessionalItem(
          professionalIdentifier: 'professional-1',
          professionalName: 'Maria',
          cityDisplayName: 'Canoas - RS',
          categoryName: 'Eletricista',
          profileClassification: 'Perfil completo',
          availabilityLabel: 'Disponivel hoje',
          blocked: false,
        ),
      ],
      professionalReports: [
        AdministrativeProfessionalReportItem(
          professionalReportIdentifier: 'report-1',
          professionalIdentifier: 'professional-1',
          professionalName: 'Maria',
          reportReasonLabel: 'Fraude',
          seriousCase: true,
          moderationStatusLabel: 'Pendente',
          createdAtLabel: '17/05/2026 10:00',
        ),
      ],
      reviewAnalysisRequests: [
        AdministrativeReviewAnalysisItem(
          reviewAnalysisRequestIdentifier: 'analysis-1',
          professionalReviewIdentifier: 'review-1',
          professionalIdentifier: 'professional-1',
          professionalName: 'Maria',
          requestedByProfessionalIdentifier: 'professional-1',
          moderationStatusLabel: 'Pendente',
          createdAtLabel: '17/05/2026 11:00',
        ),
      ],
      categoryNames: ['Eletricista'],
      administrativeMetrics: AdministrativeMetricsSummary(
        professionalCount: 1,
        professionalReportCount: 1,
        reviewAnalysisRequestCount: 1,
        serviceCategoryCount: 1,
      ),
      functionalMetrics: AdministrativeFunctionalMetricsSummary(
        searchCount: 2,
        topSearchCategories: [
          AdministrativeLabeledMetric(label: 'Eletricista', value: '2'),
        ],
      ),
    );

    // WHEN
    final updatedState = originalState.copyWith(
      loading: true,
      errorMessage: null,
      statusMessage: 'Atualizando console.',
      categoryNames: const ['Eletricista', 'Pintora'],
    );

    // THEN
    expect(updatedState.loading, isTrue);
    expect(updatedState.errorMessage, isNull);
    expect(updatedState.statusMessage, 'Atualizando console.');
    expect(updatedState.hasContent, isTrue);
    expect(updatedState.professionals.single.professionalName, 'Maria');
    expect(updatedState.professionalReports.single.seriousCase, isTrue);
    expect(
      updatedState.reviewAnalysisRequests.single.professionalReviewIdentifier,
      'review-1',
    );
    expect(updatedState.categoryNames, ['Eletricista', 'Pintora']);
    expect(updatedState.administrativeMetrics.professionalCount, 1);
    expect(updatedState.functionalMetrics.searchCount, 2);
    expect(
      updatedState.functionalMetrics.topSearchCategories.single.label,
      'Eletricista',
    );
  });
}
