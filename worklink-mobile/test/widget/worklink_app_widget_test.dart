import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_app_configuration.dart';
import 'package:worklink_mobile/main.dart';

void main() {
  testWidgets('GIVEN app inicial WHEN renderizar THEN deve exibir tela de descoberta', (tester) async {
    // GIVEN
    const application = WorkLinkApp();

    // WHEN
    await tester.pumpWidget(application);

    // THEN
    expect(find.text('Descobrir profissionais'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
  });

  testWidgets('GIVEN nome configurado WHEN renderizar THEN deve manter fluxo de descoberta', (tester) async {
    // GIVEN
    const applicationConfiguration = WorkLinkAppConfiguration(applicationName: 'WorkLink Local');
    const application = WorkLinkApp(applicationConfiguration: applicationConfiguration);

    // WHEN
    await tester.pumpWidget(application);

    // THEN
    expect(find.text('Descobrir profissionais'), findsOneWidget);
    expect(find.text('Ana Pintora'), findsOneWidget);
  });
}
