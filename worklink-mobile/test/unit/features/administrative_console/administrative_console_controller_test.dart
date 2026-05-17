import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_controller.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_state.dart';
import 'package:worklink_mobile/services/exceptions.dart';

void main() {
  test(
      'GIVEN acoes administrativas bem sucedidas WHEN operar controller THEN deve publicar novo estado',
      () async {
    // GIVEN
    final loadedState = administrativeConsoleStateFixture.copyWith(
      statusMessage: 'Console recarregado.',
    );
    final controller = AdministrativeConsoleController(
      loadAdministrativeConsole: () async => loadedState,
      blockProfessional: (_) async => loadedState,
      unblockProfessional: (_) async => loadedState,
      approveProfessionalReport: (_) async => loadedState,
      escalateProfessionalReport: (_) async => loadedState,
      keepReviewPublic: (_) async => loadedState,
      hideReviewFromPublic: (_) async => loadedState,
      registerCategory: (_) async => loadedState,
    );

    // WHEN
    await controller.loadAdministrativeConsoleAsync();
    await controller.blockProfessionalAsync('professional-1');
    await controller.unblockProfessionalAsync('professional-1');
    await controller.approveProfessionalReportAsync('report-1');
    await controller.escalateProfessionalReportAsync('report-1');
    await controller.keepReviewPublicAsync('analysis-1');
    await controller.hideReviewFromPublicAsync('analysis-1');
    await controller.registerCategoryAsync('Eletricista');

    // THEN
    expect(controller.state.loading, isFalse);
    expect(controller.state.errorMessage, isNull);
    expect(controller.state.statusMessage, 'Console recarregado.');
    expect(controller.state.professionals.single.professionalName, 'Maria');
  });

  test(
      'GIVEN falhas administrativas WHEN executar controller THEN deve mapear mensagens previsiveis',
      () async {
    // GIVEN
    final authorizationController = AdministrativeConsoleController(
      loadAdministrativeConsole: () async =>
          throw const AuthorizationException(message: 'forbidden'),
      blockProfessional: (_) async => administrativeConsoleStateFixture,
      unblockProfessional: (_) async => administrativeConsoleStateFixture,
      approveProfessionalReport: (_) async => administrativeConsoleStateFixture,
      escalateProfessionalReport: (_) async =>
          administrativeConsoleStateFixture,
      keepReviewPublic: (_) async => administrativeConsoleStateFixture,
      hideReviewFromPublic: (_) async => administrativeConsoleStateFixture,
      registerCategory: (_) async => administrativeConsoleStateFixture,
    );
    final validationController = AdministrativeConsoleController(
      loadAdministrativeConsole: () async => administrativeConsoleStateFixture,
      blockProfessional: (_) async =>
          throw const ValidationException(message: 'invalid'),
      unblockProfessional: (_) async => administrativeConsoleStateFixture,
      approveProfessionalReport: (_) async => administrativeConsoleStateFixture,
      escalateProfessionalReport: (_) async =>
          administrativeConsoleStateFixture,
      keepReviewPublic: (_) async => administrativeConsoleStateFixture,
      hideReviewFromPublic: (_) async => administrativeConsoleStateFixture,
      registerCategory: (_) async => administrativeConsoleStateFixture,
    );
    final genericController = AdministrativeConsoleController(
      loadAdministrativeConsole: () async => administrativeConsoleStateFixture,
      blockProfessional: (_) async => administrativeConsoleStateFixture,
      unblockProfessional: (_) async =>
          throw StateError('backend indisponivel'),
      approveProfessionalReport: (_) async => administrativeConsoleStateFixture,
      escalateProfessionalReport: (_) async =>
          administrativeConsoleStateFixture,
      keepReviewPublic: (_) async => administrativeConsoleStateFixture,
      hideReviewFromPublic: (_) async => administrativeConsoleStateFixture,
      registerCategory: (_) async => administrativeConsoleStateFixture,
    );

    // WHEN
    await authorizationController.loadAdministrativeConsoleAsync();
    await validationController.blockProfessionalAsync('professional-1');
    await genericController.unblockProfessionalAsync('professional-1');

    // THEN
    expect(
      authorizationController.state.errorMessage,
      'Acesso administrativo negado para esta sessao.',
    );
    expect(
      validationController.state.errorMessage,
      'Nao foi possivel concluir a acao administrativa informada.',
    );
    expect(
      genericController.state.errorMessage,
      'Nao foi possivel carregar o console administrativo agora.',
    );
  });
}

const administrativeConsoleStateFixture = AdministrativeConsoleState(
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
);
