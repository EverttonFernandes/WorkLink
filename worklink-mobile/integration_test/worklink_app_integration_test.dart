import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:worklink_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'GIVEN usuario anonimo WHEN autenticar pelo gate do detalhe e sair THEN deve retomar jornada anonima',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();
    const professionalIdentifier = 'ana-costa-energia-residencial';

    // WHEN
    await tester.pumpWidget(application);
    await tester.pumpAndSettle();
    final professionalProfileButton = find.byKey(
      const ValueKey(
        'open-professional-profile-$professionalIdentifier',
      ),
    );
    await tester.scrollUntilVisible(
      professionalProfileButton,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(professionalProfileButton);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('authentication-email-field')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'senha-segura-123',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('sign-in-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in-button')));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Perfil do profissional'), findsOneWidget);
    expect(find.text('Ana Costa Energia Residencial'), findsOneWidget);

    // WHEN
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('open-customer-profile-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('customer-profile-logout')));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Buscar profissionais'), findsOneWidget);
    expect(find.text('Explore antes de entrar'), findsOneWidget);
  });
}
