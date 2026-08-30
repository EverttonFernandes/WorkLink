import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_controller.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_screen.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    CustomerAuthenticationController controller, {
    ValueChanged<String>? onAuthenticationCompleted,
    Size size = const Size(430, 932),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerAuthenticationScreen(
          customerAuthenticationController: controller,
          onAuthenticationCompleted: onAuthenticationCompleted,
        ),
      ),
    );
  }

  testWidgets('GIVEN tela inicial THEN deve mostrar somente login local',
      (tester) async {
    await pumpScreen(tester, CustomerAuthenticationController());

    expect(find.widgetWithText(AppBar, 'Profissional Perto'), findsNothing);
    expect(
      find.text(
        'Entre ou crie sua conta para ver o perfil completo do profissional.',
      ),
      findsOneWidget,
    );
    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('authentication-email-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('authentication-password-field')),
      findsOneWidget,
    );
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Apple'), findsNothing);
    expect(find.textContaining('WhatsApp'), findsNothing);
    expect(find.text('SMS'), findsNothing);
  });

  testWidgets('GIVEN credenciais validas WHEN entrar THEN deve concluir fluxo',
      (tester) async {
    final authenticated = <String>[];
    final controller = CustomerAuthenticationController(
      authenticateWithEmailAndPassword: ({
        required emailAddress,
        required password,
      }) async {},
    );
    await pumpScreen(
      tester,
      controller,
      onAuthenticationCompleted: authenticated.add,
    );

    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'senha-segura-123',
    );
    await tester.tap(find.byKey(const ValueKey('sign-in-button')));
    await tester.pumpAndSettle();

    expect(authenticated, ['cliente@exemplo.com']);
  });

  testWidgets(
      'GIVEN login pendente WHEN aguardar THEN deve exibir carregamento',
      (tester) async {
    final authenticationCompleter = Completer<void>();
    final controller = CustomerAuthenticationController(
      authenticateWithEmailAndPassword: ({
        required emailAddress,
        required password,
      }) =>
          authenticationCompleter.future,
    );
    await pumpScreen(tester, controller);
    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'senha-segura-123',
    );

    await tester.tap(find.byKey(const ValueKey('sign-in-button')));
    await tester.pump();

    expect(find.text('Aguarde...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    authenticationCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('GIVEN credenciais recusadas WHEN entrar THEN deve exibir erro',
      (tester) async {
    final controller = CustomerAuthenticationController(
      authenticateWithEmailAndPassword: ({
        required emailAddress,
        required password,
      }) async {
        throw StateError('credencial recusada');
      },
    );
    await pumpScreen(tester, controller);
    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'senha-segura-123',
    );

    await tester.tap(find.byKey(const ValueKey('sign-in-button')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível entrar. Confira seus dados e tente novamente.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('GIVEN cadastro selecionado THEN deve exibir campos e aceite',
      (tester) async {
    await pumpScreen(tester, CustomerAuthenticationController());

    await tester.tap(find.byKey(const ValueKey('sign-up-mode-button')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Crie sua conta para ver perfis completos e seguir com segurança.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('authentication-full-name-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('authentication-phone-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('authentication-email-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('authentication-password-confirmation-field'),
      ),
      findsOneWidget,
    );
    expect(find.text('Celular não verificado'), findsOneWidget);
    expect(find.textContaining('Termos de Uso'), findsOneWidget);
  });

  testWidgets('GIVEN senha oculta WHEN tocar no olho THEN deve alternar',
      (tester) async {
    final controller = CustomerAuthenticationController();
    await pumpScreen(tester, controller);

    expect(controller.state.passwordObscured, isTrue);
    await tester.tap(find.byKey(const ValueKey('toggle-password-visibility')));
    await tester.pump();

    expect(controller.state.passwordObscured, isFalse);
  });

  testWidgets('GIVEN esqueci senha THEN deve abrir solicitacao e redefinicao',
      (tester) async {
    final controller = CustomerAuthenticationController(
      requestPasswordRecovery: ({required emailAddress}) async {},
    );
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    expect(find.text('Recuperar acesso'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.tap(find.byKey(const ValueKey('request-recovery-button')));
    await tester.pumpAndSettle();

    expect(find.text('Definir nova senha'), findsOneWidget);
    expect(find.byKey(const ValueKey('recovery-token-field')), findsOneWidget);
  });

  testWidgets(
      'GIVEN recuperacao preenchida WHEN redefinir THEN deve exibir sucesso',
      (tester) async {
    final controller = CustomerAuthenticationController(
      requestPasswordRecovery: ({required emailAddress}) async {},
      resetPassword: ({
        required recoveryToken,
        required newPassword,
        required newPasswordConfirmation,
      }) async {},
    );
    await pumpScreen(tester, controller);
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await tester.tap(find.byKey(const ValueKey('request-recovery-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recovery-token-field')),
      'TOKEN-VALIDO',
    );
    await tester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'nova-senha-segura',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('authentication-password-confirmation-field'),
      ),
      'nova-senha-segura',
    );

    await tester.tap(find.byKey(const ValueKey('reset-password-button')));
    await tester.pumpAndSettle();

    expect(find.text('Senha alterada. Entre novamente.'), findsOneWidget);
    expect(find.byKey(const ValueKey('sign-in-button')), findsOneWidget);
  });

  testWidgets('GIVEN tela pequena e cadastro THEN deve permitir rolagem',
      (tester) async {
    await pumpScreen(
      tester,
      CustomerAuthenticationController(),
      size: const Size(320, 560),
    );
    await tester.tap(find.byKey(const ValueKey('sign-up-mode-button')));
    await tester.pumpAndSettle();

    expect(find.byType(Scrollable), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GIVEN escala de texto ampliada WHEN abrir cadastro THEN deve manter conteudo acessivel',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(
      tester.platformDispatcher.clearTextScaleFactorTestValue,
    );
    await pumpScreen(
      tester,
      CustomerAuthenticationController(),
      size: const Size(393, 852),
    );
    await tester.tap(find.byKey(const ValueKey('sign-up-mode-button')));
    await tester.pumpAndSettle();

    expect(find.byType(Scrollable), findsWidgets);
    expect(
      find.byKey(const ValueKey('authentication-full-name-field')),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    expect(find.textContaining('Termos de Uso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GIVEN autenticacao concluida WHEN renderizar THEN deve exibir sucesso',
      (tester) async {
    await pumpScreen(
      tester,
      CustomerAuthenticationController(
        initialState: const CustomerAuthenticationState(
          mode: CustomerAuthenticationMode.authenticated,
          authenticatedEmailAddress: 'cliente@exemplo.com',
        ),
      ),
    );

    expect(find.text('Conta autenticada'), findsOneWidget);
    expect(find.textContaining('cliente@exemplo.com'), findsOneWidget);
  });
}
