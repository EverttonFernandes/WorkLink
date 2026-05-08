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
}
