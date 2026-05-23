import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_controller.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_screen.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_state.dart';

void main() {
  testWidgets(
      'GIVEN console administrativo carregado WHEN renderizar THEN deve exibir operacoes principais',
      (widgetTester) async {
    // GIVEN
    await widgetTester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => widgetTester.binding.setSurfaceSize(null));
    final controller = AdministrativeConsoleController(
      loadAdministrativeConsole: () async => administrativeConsoleStateFixture,
      blockProfessional: (_) async => administrativeConsoleStateFixture,
      unblockProfessional: (_) async => administrativeConsoleStateFixture,
      approveProfessionalReport: (_) async => administrativeConsoleStateFixture,
      escalateProfessionalReport: (_) async =>
          administrativeConsoleStateFixture,
      keepReviewPublic: (_) async => administrativeConsoleStateFixture,
      hideReviewFromPublic: (_) async => administrativeConsoleStateFixture,
      registerCategory: (_) async => administrativeConsoleStateFixture,
    );

    // WHEN
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AdministrativeConsoleScreen(
          administrativeConsoleController: controller,
        ),
      ),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Console administrativo'), findsOneWidget);
    expect(find.text('Resumo operacional'), findsOneWidget);
    expect(find.text('Gestao minima de categorias'), findsOneWidget);
    await widgetTester.scrollUntilVisible(
      find.byKey(const ValueKey('administrative-professional-professional-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Maria Eletricista'), findsWidgets);
    await widgetTester.scrollUntilVisible(
      find.byKey(const ValueKey('administrative-report-report-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Maria Eletricista - Perfil falso'), findsOneWidget);
    expect(find.text('Ocultar'), findsOneWidget);
  });

  testWidgets(
      'GIVEN console sem permissao WHEN carregar THEN deve exibir bloqueio administrativo',
      (widgetTester) async {
    // GIVEN
    final controller = AdministrativeConsoleController(
      initialState: const AdministrativeConsoleState(
        errorMessage: 'Acesso administrativo negado para esta sessao.',
      ),
      loadAdministrativeConsole: () async => const AdministrativeConsoleState(
        errorMessage: 'Acesso administrativo negado para esta sessao.',
      ),
      blockProfessional: (_) async => const AdministrativeConsoleState(),
      unblockProfessional: (_) async => const AdministrativeConsoleState(),
      approveProfessionalReport: (_) async => const AdministrativeConsoleState(),
      escalateProfessionalReport: (_) async => const AdministrativeConsoleState(),
      keepReviewPublic: (_) async => const AdministrativeConsoleState(),
      hideReviewFromPublic: (_) async => const AdministrativeConsoleState(),
      registerCategory: (_) async => const AdministrativeConsoleState(),
    );

    // WHEN
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AdministrativeConsoleScreen(
          administrativeConsoleController: controller,
        ),
      ),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(
      find.text('Acesso administrativo negado para esta sessao.'),
      findsOneWidget,
    );
  });
}

const administrativeConsoleStateFixture = AdministrativeConsoleState(
  statusMessage: 'Console administrativo carregado.',
  professionals: [
    AdministrativeProfessionalItem(
      professionalIdentifier: 'professional-1',
      professionalName: 'Maria Eletricista',
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
      professionalName: 'Maria Eletricista',
      reportReasonLabel: 'Perfil falso',
      seriousCase: false,
      moderationStatusLabel: 'Pendente',
      createdAtLabel: '15/05/2026 10:00',
    ),
  ],
  reviewAnalysisRequests: [
    AdministrativeReviewAnalysisItem(
      reviewAnalysisRequestIdentifier: 'analysis-1',
      professionalReviewIdentifier: 'review-1',
      professionalIdentifier: 'professional-1',
      professionalName: 'Maria Eletricista',
      requestedByProfessionalIdentifier: 'professional-1',
      moderationStatusLabel: 'Pendente',
      createdAtLabel: '15/05/2026 11:00',
    ),
  ],
  categoryNames: ['Eletricista', 'Pintora'],
  administrativeMetrics: AdministrativeMetricsSummary(
    professionalCount: 1,
    professionalReportCount: 1,
    reviewAnalysisRequestCount: 1,
    serviceCategoryCount: 2,
  ),
  functionalMetrics: AdministrativeFunctionalMetricsSummary(
    searchCount: 10,
    searchWithoutResultCount: 1,
    contactCount: 3,
    postContactFeedbackCount: 2,
    reviewCount: 2,
    anonymousReviewCount: 1,
    averageRating: 4.5,
    respondedContactPercentage: 80,
    topSearchCategories: [
      AdministrativeLabeledMetric(label: 'Eletricista', value: '7'),
    ],
  ),
);
