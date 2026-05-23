import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_controller.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_screen.dart';

void main() {
  Future<void> pumpCustomerAuthenticationScreen(
    WidgetTester widgetTester,
    CustomerAuthenticationController customerAuthenticationController, {
    ValueChanged<String>? onAuthenticationCompleted,
  }) async {
    await widgetTester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => widgetTester.binding.setSurfaceSize(null));
    await widgetTester.pumpWidget(
      MaterialApp(
        home: CustomerAuthenticationScreen(
          customerAuthenticationController: customerAuthenticationController,
          onAuthenticationCompleted: onAuthenticationCompleted,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN tela de telefone WHEN renderizar THEN deve manter chamada para continuar com celular',
      (widgetTester) async {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();

    // WHEN
    await pumpCustomerAuthenticationScreen(
      widgetTester,
      customerAuthenticationController,
    );

    // THEN
    expect(find.text('Continuar com seu celular'), findsOneWidget);
    expect(find.byKey(const ValueKey('customer-phone-field')), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets(
      'GIVEN telefone valido WHEN continuar THEN deve abrir tela de verificacao',
      (widgetTester) async {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    await pumpCustomerAuthenticationScreen(
      widgetTester,
      customerAuthenticationController,
    );

    // WHEN
    await widgetTester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('request-code-button')),
    );
    await widgetTester.tap(find.byKey(const ValueKey('request-code-button')));
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Verifique seu numero'), findsOneWidget);
    expect(find.text('(51) 9 9999-1234'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('verification-code-field')),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN codigo correto WHEN confirmar THEN deve emitir telefone autenticado',
      (widgetTester) async {
    // GIVEN
    final authenticatedPhoneNumbers = <String>[];
    final customerAuthenticationController = CustomerAuthenticationController();
    await pumpCustomerAuthenticationScreen(
      widgetTester,
      customerAuthenticationController,
      onAuthenticationCompleted: authenticatedPhoneNumbers.add,
    );
    await widgetTester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('request-code-button')),
    );
    await widgetTester.tap(find.byKey(const ValueKey('request-code-button')));
    await widgetTester.pumpAndSettle();

    // WHEN
    await widgetTester.enterText(
      find.byKey(const ValueKey('verification-code-field')),
      '1234',
    );
    await widgetTester.tap(find.byKey(const ValueKey('confirm-code-button')));
    await widgetTester.pumpAndSettle();

    // THEN
    expect(authenticatedPhoneNumbers, ['51999991234']);
    expect(find.text('Telefone verificado'), findsOneWidget);
  });

  testWidgets(
      'GIVEN codigo incorreto WHEN confirmar THEN deve mostrar erro generico',
      (widgetTester) async {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    await pumpCustomerAuthenticationScreen(
      widgetTester,
      customerAuthenticationController,
    );
    await widgetTester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('request-code-button')),
    );
    await widgetTester.tap(find.byKey(const ValueKey('request-code-button')));
    await widgetTester.pumpAndSettle();

    // WHEN
    await widgetTester.enterText(
      find.byKey(const ValueKey('verification-code-field')),
      '0000',
    );
    await widgetTester.tap(find.byKey(const ValueKey('confirm-code-button')));
    await widgetTester.pumpAndSettle();

    // THEN
    expect(
      find.text('Nao foi possivel concluir a autenticacao.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN verificacao aberta WHEN editar telefone THEN deve voltar para entrada de telefone',
      (widgetTester) async {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    await pumpCustomerAuthenticationScreen(
      widgetTester,
      customerAuthenticationController,
    );
    await widgetTester.enterText(
      find.byKey(const ValueKey('customer-phone-field')),
      '(51) 9 9999-1234',
    );
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('request-code-button')),
    );
    await widgetTester.tap(find.byKey(const ValueKey('request-code-button')));
    await widgetTester.pumpAndSettle();

    // WHEN
    await widgetTester.tap(find.byKey(const ValueKey('edit-phone-button')));
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Continuar com seu celular'), findsOneWidget);
    expect(find.byKey(const ValueKey('customer-phone-field')), findsOneWidget);
  });
}
