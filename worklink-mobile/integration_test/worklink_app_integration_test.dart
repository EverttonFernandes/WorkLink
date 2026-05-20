import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:worklink_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'GIVEN app instalado WHEN abrir fluxo inicial THEN deve exibir descoberta',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();

    // WHEN
    await tester.pumpWidget(application);
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Descobrir profissionais'), findsOneWidget);
    expect(find.byKey(const ValueKey('keyword-search-field')), findsOneWidget);
  });
}
