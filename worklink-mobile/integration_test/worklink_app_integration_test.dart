import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:worklink_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'GIVEN app instalado WHEN abrir fluxo inicial THEN deve exibir nome WorkLink',
      (tester) async {
    // GIVEN
    const application = WorkLinkApp.preview();

    // WHEN
    await tester.pumpWidget(application);

    // THEN
    expect(find.text('WorkLink'), findsOneWidget);
  });
}
