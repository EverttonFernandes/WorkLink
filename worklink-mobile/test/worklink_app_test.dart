import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/main.dart';

void main() {
  testWidgets('GIVEN app inicial WHEN renderizar THEN deve exibir nome WorkLink', (tester) async {
    // GIVEN
    const application = WorkLinkApp();

    // WHEN
    await tester.pumpWidget(application);

    // THEN
    expect(find.text('WorkLink'), findsOneWidget);
  });
}
