import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_controller.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_state.dart';

void main() {
  test(
      'GIVEN denuncia sem motivo WHEN enviar THEN deve exibir erro e nao submeter',
      () async {
    // GIVEN
    var submitCount = 0;
    final controller = ProfessionalReportController(
      professionalIdentifier: 'professional-1',
      submitProfessionalReport: (_, __) async {
        submitCount++;
      },
    );

    // WHEN
    await controller.submitReport();

    // THEN
    expect(submitCount, 0);
    expect(controller.state.errorMessage, contains('Selecione um motivo'));
  });

  test(
      'GIVEN denuncia preenchida WHEN enviar THEN deve submeter motivo descricao e evidencia',
      () async {
    // GIVEN
    ProfessionalReportState? submittedState;
    final controller = ProfessionalReportController(
      professionalIdentifier: 'professional-1',
      submitProfessionalReport: (_, reportState) async {
        submittedState = reportState;
      },
    );
    controller.selectReason(ProfessionalReportReason.fraud);
    controller.updateDescription('  Perfil falso  ');
    controller.attachEvidence('evidencia.pdf');

    // WHEN
    await controller.submitReport();

    // THEN
    expect(submittedState?.selectedReason, ProfessionalReportReason.fraud);
    expect(submittedState?.normalizedDescription, 'Perfil falso');
    expect(submittedState?.evidenceFileName, 'evidencia.pdf');
    expect(controller.state.submitted, isTrue);
  });

  test('GIVEN motivo grave WHEN selecionar THEN deve exibir orientacao',
      () async {
    // GIVEN
    final controller = ProfessionalReportController(
      professionalIdentifier: 'professional-1',
      submitProfessionalReport: (_, __) async {},
    );

    // WHEN
    controller.selectReason(ProfessionalReportReason.threat);

    // THEN
    expect(controller.state.shouldShowAuthorityGuidance, isTrue);
  });
}
