import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_app_configuration.dart';
import 'package:worklink_mobile/main.dart';

void main() {
  testWidgets(
      'GIVEN app inicial WHEN renderizar THEN deve exibir tela de descoberta',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();

    // WHEN
    await tester.pumpWidget(application);

    // THEN
    expect(find.text('Descobrir profissionais'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
  });

  testWidgets(
      'GIVEN nome configurado WHEN renderizar THEN deve manter fluxo de descoberta',
      (tester) async {
    // GIVEN
    const applicationConfiguration =
        WorkLinkAppConfiguration(applicationName: 'WorkLink Local');
    const application =
        WorkLinkApp(applicationConfiguration: applicationConfiguration);

    // WHEN
    await tester.pumpWidget(application);

    // THEN
    expect(find.text('Descobrir profissionais'), findsOneWidget);
    expect(find.text('Ana Pintora'), findsOneWidget);
  });

  testWidgets(
      'GIVEN listagem inicial WHEN abrir profissional THEN deve navegar para perfil publico',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Perfil do profissional'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(
      find.text('Completude do perfil não garante qualidade do serviço.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN cliente sem login WHEN tentar contato THEN deve navegar para autenticacao',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);
    await tester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await tester.pumpAndSettle();

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Continuar com seu celular'), findsOneWidget);
    expect(find.byKey(const ValueKey('customer-phone-field')), findsOneWidget);
  });

  testWidgets(
      'GIVEN cliente autenticado WHEN tentar contato THEN deve navegar para tela de contato WhatsApp',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);
    await tester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await tester.tap(find.byKey(const ValueKey('request-code-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('verification-code-field')),
      '1234',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-code-button')));
    await tester.pumpAndSettle();

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Falar com o profissional'), findsOneWidget);
    expect(
      find.text('A negociação acontece fora do WorkLink pelo WhatsApp.'),
      findsOneWidget,
    );
    expect(
      find.text('O WorkLink não garante a execução do serviço contratado.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN contato WhatsApp iniciado WHEN responder pos-contato THEN deve navegar para feedback estruturado',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);
    await tester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await tester.tap(find.byKey(const ValueKey('request-code-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('verification-code-field')),
      '1234',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-code-button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await tester.pumpAndSettle();

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Pós-contato'), findsOneWidget);
    expect(find.text('Conseguiu falar?'), findsOneWidget);
    expect(find.text('Como foi a resposta?'), findsOneWidget);
    expect(find.text('O serviço foi realizado?'), findsOneWidget);
  });

  testWidgets(
      'GIVEN pos-contato com servico realizado WHEN avaliar THEN deve navegar para avaliacao profissional',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);
    await tester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await tester.tap(find.byKey(const ValueKey('request-code-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('verification-code-field')),
      '1234',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-code-button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('contact-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Consegui falar'));
    await tester.tap(find.text('Respondeu rápido'));
    await tester.tap(find.text('Serviço realizado'));
    await tester.tap(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await tester.pumpAndSettle();

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('open-professional-review-button')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Avaliar profissional'), findsOneWidget);
    expect(find.text('Nota obrigatória'), findsOneWidget);
  });

  testWidgets(
      'GIVEN app inicial WHEN abrir cadastro profissional THEN deve navegar para cadastro progressivo',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);

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
      'GIVEN perfil publico WHEN denunciar profissional THEN deve navegar para tela de denuncia',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp();
    await tester.pumpWidget(application);
    await tester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await tester.pumpAndSettle();

    // WHEN
    await tester.tap(
      find.byKey(const ValueKey('report-professional-maria-eletricista')),
    );
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Denunciar profissional'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(find.text('Motivo'), findsOneWidget);
  });
}
