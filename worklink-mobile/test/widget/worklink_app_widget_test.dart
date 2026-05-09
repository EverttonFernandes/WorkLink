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
      'GIVEN cliente autenticado WHEN tentar contato THEN deve manter perfil publico',
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
    await tester.pump();

    // THEN
    expect(find.text('Perfil do profissional'), findsOneWidget);
    expect(find.text('Contato autenticado para Maria Eletricista'), findsOneWidget);
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
}
