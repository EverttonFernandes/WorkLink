import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_app_configuration.dart';
import 'package:worklink_mobile/app/worklink_application_gateway.dart';
import 'package:worklink_mobile/features/administrative_console/administrative_console_state.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_state.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile.dart';
import 'package:worklink_mobile/main.dart';
import 'package:worklink_mobile/services/exceptions.dart';

const previewProfessionalIdentifier = 'ana-costa-energia-residencial';
const previewProfessionalName = 'Ana Costa Energia Residencial';
const secondaryPreviewProfessionalName = 'Bruno Silveira Hidráulica';
const openPreviewProfessionalProfileKey =
    'open-professional-profile-$previewProfessionalIdentifier';
const contactPreviewProfessionalKey =
    'contact-professional-$previewProfessionalIdentifier';
const reportPreviewProfessionalKey =
    'report-professional-$previewProfessionalIdentifier';

void main() {
  Future<void> pumpWorkLinkApp(
    WidgetTester tester,
    Widget application, {
    Size surfaceSize = const Size(800, 1800),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(application);
  }

  Future<void> authenticateCustomerFromCurrentScreen(
    WidgetTester tester,
  ) async {
    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'senha-segura-123',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('sign-in-button')));
    await tester.tap(find.byKey(const ValueKey('sign-in-button')));
    await tester.pumpAndSettle();
  }

  Future<void> authenticateCustomerAfterProfessionalGate(
    WidgetTester tester,
  ) async {
    await tester.tap(
      find.byKey(const ValueKey(openPreviewProfessionalProfileKey)),
    );
    await tester.pumpAndSettle();
    await authenticateCustomerFromCurrentScreen(tester);
  }

  testWidgets(
      'GIVEN app inicial WHEN renderizar THEN deve exibir tela de descoberta',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();

    // WHEN
    await pumpWorkLinkApp(tester, application);

    // THEN
    expect(find.text('Buscar profissionais'), findsOneWidget);
    expect(find.text(previewProfessionalName), findsOneWidget);
    expect(find.text('Explore antes de entrar'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('guest-open-sign-in-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('guest-open-sign-up-button')),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN nome configurado WHEN renderizar THEN deve manter fluxo de descoberta',
      (tester) async {
    // GIVEN
    const applicationConfiguration =
        WorkLinkAppConfiguration(applicationName: 'Profissional Perto Local');
    const application =
        WorkLinkApp.preview(applicationConfiguration: applicationConfiguration);

    // WHEN
    await pumpWorkLinkApp(tester, application);

    // THEN
    expect(find.text('Buscar profissionais'), findsOneWidget);
    expect(find.text(secondaryPreviewProfessionalName), findsOneWidget);
  });

  testWidgets(
      'GIVEN banner inicial WHEN continuar sem login THEN deve ocultar CTA e manter descoberta publica',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('guest-continue-without-login-button')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Explore antes de entrar'), findsNothing);
    expect(find.text('Buscar profissionais'), findsOneWidget);
    expect(find.text(previewProfessionalName), findsOneWidget);
  });

  testWidgets(
      'GIVEN tela estreita WHEN renderizar card anonimo THEN deve manter acoes acessiveis sem overflow',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();

    // WHEN
    await pumpWorkLinkApp(
      tester,
      application,
      surfaceSize: const Size(430, 700),
    );

    // THEN
    expect(find.text('Explore antes de entrar'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('guest-open-sign-in-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('guest-open-sign-up-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GIVEN usuario anonimo WHEN tentar abrir detalhe THEN deve navegar para autenticacao',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey(openPreviewProfessionalProfileKey)),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('authentication-email-field')),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN usuario anonimo WHEN autenticar apos gate do detalhe THEN deve abrir o perfil solicitado',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await authenticateCustomerAfterProfessionalGate(tester);

    // THEN
    expect(find.text('Perfil do profissional'), findsOneWidget);
    expect(find.text(previewProfessionalName), findsOneWidget);
  });

  testWidgets(
      'GIVEN sessao expirada WHEN abrir detalhe protegido THEN deve autenticar novamente e retomar o perfil',
      (tester) async {
    // GIVEN
    final applicationGateway = _ProfessionalDetailAccessErrorGateway(
      statusCode: 401,
      failOnlyFirstAttempt: true,
    );
    final application = WorkLinkApp(applicationGateway: applicationGateway);
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey(openPreviewProfessionalProfileKey)),
    );
    await tester.pumpAndSettle();
    await authenticateCustomerFromCurrentScreen(tester);
    await tester.pumpAndSettle();

    // THEN
    expect(applicationGateway.logoutCallCount, 1);
    expect(applicationGateway.loadProfessionalProfileCallCount, 2);
    expect(find.text('Perfil do profissional'), findsOneWidget);
    expect(find.text(previewProfessionalName), findsOneWidget);
  });

  testWidgets(
      'GIVEN cliente autenticado WHEN detalhe retornar 403 THEN deve preservar sessao e informar falta de autorizacao',
      (tester) async {
    // GIVEN
    final applicationGateway = _ProfessionalDetailAccessErrorGateway(
      statusCode: 403,
    );
    final application = WorkLinkApp(applicationGateway: applicationGateway);
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey(openPreviewProfessionalProfileKey)),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(applicationGateway.logoutCallCount, 0);
    expect(
      find.text('Você não tem autorização para acessar este recurso.'),
      findsOneWidget,
    );
    expect(find.text('Explore antes de entrar'), findsNothing);
  });

  testWidgets(
      'GIVEN cliente autenticado WHEN tentar contato THEN deve navegar para tela de contato WhatsApp',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);
    await authenticateCustomerAfterProfessionalGate(tester);

    // WHEN
    await tester.tap(find.byKey(const ValueKey(contactPreviewProfessionalKey)));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Falar com o profissional'), findsOneWidget);
    expect(
      find.textContaining('Você será redirecionado para o WhatsApp'),
      findsOneWidget,
    );
    expect(
      find.text('Combine valores e prazos diretamente'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN contato WhatsApp iniciado WHEN responder pos-contato THEN deve navegar para feedback estruturado',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);
    await authenticateCustomerAfterProfessionalGate(tester);
    await tester.tap(find.byKey(const ValueKey(contactPreviewProfessionalKey)));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await tester.pumpAndSettle();

    // WHEN
    await tester.ensureVisible(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Como foi seu contato?'), findsOneWidget);
    expect(
      find.text('Você conseguiu falar com o profissional?'),
      findsOneWidget,
    );
    expect(find.text('Como foi a resposta?'), findsOneWidget);
    expect(find.text('O serviço foi realizado?'), findsOneWidget);
  });

  testWidgets(
      'GIVEN pos-contato com servico realizado WHEN avaliar THEN deve navegar para avaliacao profissional',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);
    await authenticateCustomerAfterProfessionalGate(tester);
    await tester.tap(find.byKey(const ValueKey(contactPreviewProfessionalKey)));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'conversation-outcome-PostContactConversationOutcome.customerReachedProfessional',
        ),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'service-execution-PostContactServiceExecutionOutcome.servicePerformed',
        ),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'contact-responsiveness-PostContactResponsiveness.fastResponse',
        ),
      ),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();

    // WHEN
    await tester.ensureVisible(
      find.byKey(const ValueKey('open-professional-review-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('open-professional-review-button')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Avaliar profissional'), findsOneWidget);
    expect(find.text('Avalie sua experiência'), findsOneWidget);
    expect(find.text('Escolha uma nota'), findsOneWidget);
  });

  testWidgets(
      'GIVEN app inicial WHEN abrir cadastro profissional THEN deve navegar para cadastro progressivo',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('open-professional-registration-button')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Cadastro do Profissional'), findsOneWidget);
    expect(find.text('Etapa 1 de 2'), findsOneWidget);
  });

  testWidgets(
      'GIVEN console administrativo habilitado WHEN abrir atalho interno THEN deve navegar para o console',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview(
      applicationConfiguration: WorkLinkAppConfiguration(
        administrativeConsoleEnabled: true,
      ),
    );
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester
        .tap(find.byKey(const ValueKey('open-administrative-console-button')));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Console administrativo'), findsOneWidget);
    expect(find.text('Resumo operacional'), findsOneWidget);
    expect(find.text('Gestao minima de categorias'), findsOneWidget);
  });

  testWidgets(
      'GIVEN token nao administrador WHEN abrir console interno THEN deve exibir acesso negado',
      (tester) async {
    // GIVEN
    final application = WorkLinkApp(
      applicationConfiguration: const WorkLinkAppConfiguration(
        administrativeConsoleEnabled: true,
      ),
      applicationGateway: _BlockedAdministrativeGateway(),
    );
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester
        .tap(find.byKey(const ValueKey('open-administrative-console-button')));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Console administrativo'), findsOneWidget);
    expect(
      find.text('Acesso administrativo negado para esta sessao.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN cliente sem login WHEN abrir perfil do usuario THEN deve autenticar antes do perfil',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester
        .tap(find.byKey(const ValueKey('open-customer-profile-button')));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('authentication-email-field')),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN cliente autenticado WHEN abrir perfil do usuario THEN deve visualizar area do cliente',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);
    await tester
        .tap(find.byKey(const ValueKey('open-customer-profile-button')));
    await tester.pumpAndSettle();
    await authenticateCustomerFromCurrentScreen(tester);

    // THEN
    expect(find.text('Meu perfil'), findsOneWidget);
    expect(find.text('Cliente Exemplo'), findsOneWidget);
    expect(find.text('(51) 9 9999-1234'), findsOneWidget);
    expect(find.text('Profissionais salvos'), findsOneWidget);
    expect(find.text('Avaliações enviadas'), findsOneWidget);
  });

  testWidgets(
      'GIVEN sessao autenticada WHEN recurso protegido retornar 401 THEN deve limpar sessao automaticamente',
      (tester) async {
    // GIVEN
    final applicationGateway = _CustomerProfileAccessErrorGateway(
      statusCode: 401,
    );
    final application = WorkLinkApp(applicationGateway: applicationGateway);
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester
        .tap(find.byKey(const ValueKey('open-customer-profile-button')));
    await tester.pumpAndSettle();

    // THEN
    expect(applicationGateway.logoutCallCount, 1);
    expect(find.text('Explore antes de entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GIVEN sessao autenticada WHEN recurso protegido retornar 403 THEN deve preservar sessao e propagar autorizacao',
      (tester) async {
    // GIVEN
    final applicationGateway = _CustomerProfileAccessErrorGateway(
      statusCode: 403,
    );
    final application = WorkLinkApp(applicationGateway: applicationGateway);
    await pumpWorkLinkApp(tester, application);

    // WHEN
    await tester
        .tap(find.byKey(const ValueKey('open-customer-profile-button')));
    await tester.pumpAndSettle();

    // THEN
    expect(applicationGateway.logoutCallCount, 0);
    expect(
      find.text('Você não tem autorização para acessar este recurso.'),
      findsOneWidget,
    );
    expect(find.text('Explore antes de entrar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GIVEN perfil publico WHEN denunciar profissional THEN deve navegar para tela de denuncia',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    await pumpWorkLinkApp(tester, application);
    await authenticateCustomerAfterProfessionalGate(tester);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey(reportPreviewProfessionalKey)),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Denunciar profissional'), findsOneWidget);
    expect(find.text('Ana Costa Energia Residencial'), findsOneWidget);
    expect(find.text('1. Qual foi o problema?'), findsOneWidget);
  });
}

class _BlockedAdministrativeGateway extends WorkLinkPreviewGateway {
  @override
  Future<AdministrativeConsoleState> loadAdministrativeConsole() {
    throw const AuthorizationException(
      message: 'Token sem perfil administrativo.',
    );
  }
}

class _CustomerProfileAccessErrorGateway extends WorkLinkPreviewGateway {
  _CustomerProfileAccessErrorGateway({required this.statusCode});

  final int statusCode;
  int logoutCallCount = 0;

  @override
  Future<bool> restoreCustomerSession() async => true;

  @override
  Future<CustomerProfileState> loadCustomerProfile() {
    if (statusCode == 401) {
      throw AuthenticationException(
        message: 'Sessao expirada.',
        statusCode: statusCode,
      );
    }
    throw AuthorizationException(
      message: 'Acesso negado.',
      statusCode: statusCode,
    );
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }
}

class _ProfessionalDetailAccessErrorGateway extends WorkLinkPreviewGateway {
  _ProfessionalDetailAccessErrorGateway({
    required this.statusCode,
    this.failOnlyFirstAttempt = false,
  });

  final int statusCode;
  final bool failOnlyFirstAttempt;
  int loadProfessionalProfileCallCount = 0;
  int logoutCallCount = 0;

  @override
  Future<bool> restoreCustomerSession() async => true;

  @override
  Future<ProfessionalProfile> loadProfessionalProfile(
    String professionalIdentifier,
  ) async {
    loadProfessionalProfileCallCount++;
    if (failOnlyFirstAttempt && loadProfessionalProfileCallCount > 1) {
      return super.loadProfessionalProfile(professionalIdentifier);
    }
    if (statusCode == 401) {
      throw AuthenticationException(
        message: 'Sessao expirada.',
        statusCode: statusCode,
      );
    }
    throw AuthorizationException(
      message: 'Acesso negado.',
      statusCode: statusCode,
    );
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }
}
