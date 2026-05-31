import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_controller.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_screen.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_state.dart';

void main() {
  testWidgets(
      'GIVEN tela denuncia WHEN enviar sem motivo THEN deve exigir motivo',
      (widgetTester) async {
    // GIVEN
    await pumpProfessionalReportScreen(widgetTester);

    // WHEN
    await widgetTester
        .tap(find.byKey(const ValueKey('submit-professional-report')));
    await widgetTester.pump();

    // THEN
    expect(find.textContaining('Selecione um motivo'), findsOneWidget);
  });

  testWidgets(
      'GIVEN motivo grave WHEN selecionar THEN deve orientar autoridades',
      (widgetTester) async {
    // GIVEN
    await pumpProfessionalReportScreen(widgetTester);

    // WHEN
    await widgetTester.tap(find.byKey(const ValueKey('report-reason-threat')));
    await widgetTester.pump();

    // THEN
    expect(find.textContaining('autoridades competentes'), findsOneWidget);
  });

  testWidgets(
      'GIVEN denuncia preenchida WHEN enviar THEN deve registrar denuncia',
      (widgetTester) async {
    // GIVEN
    final submittedStates = <ProfessionalReportState>[];
    await pumpProfessionalReportScreen(
      widgetTester,
      submitProfessionalReport: (_, reportState) async {
        submittedStates.add(reportState);
      },
    );

    // WHEN
    await widgetTester.tap(find.byKey(const ValueKey('report-reason-fraud')));
    await widgetTester.enterText(
      find.byKey(const ValueKey('professional-report-description')),
      'Perfil falso',
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('attach-professional-report-evidence')),
    );
    await widgetTester.pump();
    await widgetTester
        .tap(find.byKey(const ValueKey('submit-professional-report')));
    await widgetTester.pump();

    // THEN
    expect(submittedStates, hasLength(1));
    expect(
      submittedStates.single.selectedReason,
      ProfessionalReportReason.fraud,
    );
    expect(submittedStates.single.normalizedDescription, 'Perfil falso');
    expect(submittedStates.single.hasEvidence, isTrue);
    expect(find.text('Denuncia enviada para analise.'), findsOneWidget);
  });
}

Future<void> pumpProfessionalReportScreen(
  WidgetTester widgetTester, {
  SubmitProfessionalReport? submitProfessionalReport,
}) {
  widgetTester.view.physicalSize = const Size(800, 1400);
  widgetTester.view.devicePixelRatio = 1;
  addTearDown(widgetTester.view.resetPhysicalSize);
  addTearDown(widgetTester.view.resetDevicePixelRatio);
  return widgetTester.pumpWidget(
    MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: ProfessionalReportScreen(
        professionalName: 'Maria Eletricista',
        professionalReportController: ProfessionalReportController(
          professionalIdentifier: 'maria-eletricista',
          submitProfessionalReport:
              submitProfessionalReport ?? (_, __) async {},
        ),
      ),
    ),
  );
}
