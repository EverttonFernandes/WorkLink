import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_controller.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';

void main() {
  test(
      'GIVEN credenciais validas WHEN entrar THEN deve autenticar email normalizado',
      () async {
    final calls = <String>[];
    final controller = CustomerAuthenticationController(
      authenticateWithEmailAndPassword: ({
        required emailAddress,
        required password,
      }) async {
        calls.add('$emailAddress:$password');
      },
    )
      ..changeEmailAddress(' Cliente@Exemplo.COM ')
      ..changePassword('senha-segura-123');

    final accepted = await controller.signIn();

    expect(accepted, isTrue);
    expect(calls, ['cliente@exemplo.com:senha-segura-123']);
    expect(controller.state.authenticated, isTrue);
    expect(controller.state.authenticatedEmailAddress, 'cliente@exemplo.com');
  });

  test('GIVEN credencial recusada WHEN entrar THEN deve mostrar erro generico',
      () async {
    final controller = CustomerAuthenticationController(
      authenticateWithEmailAndPassword: ({
        required emailAddress,
        required password,
      }) async {
        throw StateError('conta inexistente');
      },
    )
      ..changeEmailAddress('cliente@exemplo.com')
      ..changePassword('senha-segura-123');

    final accepted = await controller.signIn();

    expect(accepted, isFalse);
    expect(
      controller.state.errorMessage,
      'Não foi possível entrar. Confira seus dados e tente novamente.',
    );
  });

  test('GIVEN login pendente WHEN aguardar backend THEN deve expor loading',
      () async {
    final completer = Completer<void>();
    final controller = CustomerAuthenticationController(
      authenticateWithEmailAndPassword: ({
        required emailAddress,
        required password,
      }) =>
          completer.future,
    )
      ..changeEmailAddress('cliente@exemplo.com')
      ..changePassword('senha-segura-123');

    final future = controller.signIn();

    expect(controller.state.loading, isTrue);
    completer.complete();
    await future;
    expect(controller.state.loading, isFalse);
  });

  test('GIVEN cadastro valido WHEN criar conta THEN deve enviar todos os dados',
      () async {
    final calls = <Map<String, Object>>[];
    final controller = CustomerAuthenticationController(
      registerLocalAccount: ({
        required fullName,
        required phoneNumber,
        required emailAddress,
        required password,
        required passwordConfirmation,
        required legalTermsAccepted,
      }) async {
        calls.add({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'emailAddress': emailAddress,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
          'legalTermsAccepted': legalTermsAccepted,
        });
      },
    )
      ..selectMode(CustomerAuthenticationMode.signUp)
      ..changeFullName('Maria da Silva')
      ..changePhoneNumber('(51) 9 9999-1234')
      ..changeEmailAddress('Maria@Exemplo.COM')
      ..changePassword('senha-segura-123')
      ..changePasswordConfirmation('senha-segura-123')
      ..changeLegalTermsAccepted(true);

    final accepted = await controller.signUp();

    expect(accepted, isTrue);
    expect(calls.single, {
      'fullName': 'Maria da Silva',
      'phoneNumber': '51999991234',
      'emailAddress': 'maria@exemplo.com',
      'password': 'senha-segura-123',
      'passwordConfirmation': 'senha-segura-123',
      'legalTermsAccepted': true,
    });
    expect(controller.state.phoneVerified, isFalse);
    expect(controller.state.authenticated, isTrue);
  });

  test('GIVEN cadastro invalido WHEN criar conta THEN deve validar localmente',
      () async {
    final controller = CustomerAuthenticationController()
      ..selectMode(CustomerAuthenticationMode.signUp)
      ..changeFullName('Maria')
      ..changePhoneNumber('51')
      ..changeEmailAddress('email-invalido')
      ..changePassword('curta')
      ..changePasswordConfirmation('diferente');

    final accepted = await controller.signUp();

    expect(accepted, isFalse);
    expect(controller.state.errorMessage, contains('Revise'));
  });

  test(
      'GIVEN email WHEN solicitar recuperacao THEN deve confirmar sem enumerar conta',
      () async {
    final requested = <String>[];
    final controller = CustomerAuthenticationController(
      requestPasswordRecovery: ({required emailAddress}) async {
        requested.add(emailAddress);
      },
    )
      ..openPasswordRecovery()
      ..changeEmailAddress(' Cliente@Exemplo.COM ');

    final accepted = await controller.requestRecovery();

    expect(accepted, isTrue);
    expect(requested, ['cliente@exemplo.com']);
    expect(
      controller.state.mode,
      CustomerAuthenticationMode.passwordRecoveryReset,
    );
    expect(
      controller.state.statusMessage,
      contains('Se existir uma conta'),
    );
  });

  test('GIVEN token e nova senha WHEN redefinir THEN deve voltar ao login',
      () async {
    final calls = <String>[];
    final controller = CustomerAuthenticationController(
      resetPassword: ({
        required recoveryToken,
        required newPassword,
        required newPasswordConfirmation,
      }) async {
        calls.add('$recoveryToken:$newPassword:$newPasswordConfirmation');
      },
      initialState: const CustomerAuthenticationState(
        mode: CustomerAuthenticationMode.passwordRecoveryReset,
        emailAddress: 'cliente@exemplo.com',
      ),
    )
      ..changeRecoveryToken('ABC123')
      ..changePassword('nova-senha-segura')
      ..changePasswordConfirmation('nova-senha-segura');

    final accepted = await controller.completePasswordReset();

    expect(accepted, isTrue);
    expect(
      calls,
      ['ABC123:nova-senha-segura:nova-senha-segura'],
    );
    expect(controller.state.mode, CustomerAuthenticationMode.signIn);
    expect(controller.state.statusMessage, 'Senha alterada. Entre novamente.');
  });

  test('GIVEN senha oculta WHEN alternar THEN deve mostrar e ocultar novamente',
      () {
    final controller = CustomerAuthenticationController();

    controller.togglePasswordVisibility();
    expect(controller.state.passwordObscured, isFalse);

    controller.togglePasswordVisibility();
    expect(controller.state.passwordObscured, isTrue);
  });

  test(
      'GIVEN confirmacao oculta e modo alterado WHEN interagir THEN deve limpar campos temporarios',
      () {
    final controller = CustomerAuthenticationController()
      ..changePassword('senha-temporaria')
      ..changePasswordConfirmation('confirmacao-temporaria')
      ..changeRecoveryToken('token-temporario');

    controller.togglePasswordConfirmationVisibility();
    expect(controller.state.passwordConfirmationObscured, isFalse);

    controller.selectMode(CustomerAuthenticationMode.signUp);

    expect(controller.state.password, isEmpty);
    expect(controller.state.passwordConfirmation, isEmpty);
    expect(controller.state.recoveryToken, isEmpty);
  });

  test('GIVEN login incompleto WHEN entrar THEN deve rejeitar localmente',
      () async {
    final controller = CustomerAuthenticationController()
      ..changeEmailAddress('email-invalido');

    final accepted = await controller.signIn();

    expect(accepted, isFalse);
    expect(controller.state.errorMessage, contains('email válido'));
  });

  test('GIVEN recuperacao invalida ou indisponivel WHEN operar THEN deve falhar',
      () async {
    final invalidController = CustomerAuthenticationController()
      ..openPasswordRecovery()
      ..changeEmailAddress('email-invalido');
    expect(await invalidController.requestRecovery(), isFalse);

    final unavailableController = CustomerAuthenticationController(
      requestPasswordRecovery: ({required emailAddress}) async {
        throw StateError('indisponivel');
      },
    )
      ..openPasswordRecovery()
      ..changeEmailAddress('cliente@example.com');
    expect(await unavailableController.requestRecovery(), isFalse);
    expect(unavailableController.state.errorMessage, contains('Tente novamente'));
  });

  test('GIVEN reset invalido ou recusado WHEN concluir THEN deve manter recuperacao',
      () async {
    final invalidController = CustomerAuthenticationController(
      initialState: const CustomerAuthenticationState(
        mode: CustomerAuthenticationMode.passwordRecoveryReset,
      ),
    );
    expect(await invalidController.completePasswordReset(), isFalse);

    final refusedController = CustomerAuthenticationController(
      resetPassword: ({
        required recoveryToken,
        required newPassword,
        required newPasswordConfirmation,
      }) async {
        throw StateError('token expirado');
      },
      initialState: const CustomerAuthenticationState(
        mode: CustomerAuthenticationMode.passwordRecoveryReset,
      ),
    )
      ..changeRecoveryToken('TOKEN')
      ..changePassword('nova-senha-segura')
      ..changePasswordConfirmation('nova-senha-segura');

    expect(await refusedController.completePasswordReset(), isFalse);
    expect(refusedController.state.errorMessage, contains('novo código'));
  });

  test('GIVEN cadastro recusado WHEN criar THEN deve mostrar erro generico',
      () async {
    final controller = CustomerAuthenticationController(
      registerLocalAccount: ({
        required fullName,
        required phoneNumber,
        required emailAddress,
        required password,
        required passwordConfirmation,
        required legalTermsAccepted,
      }) async {
        throw StateError('email duplicado');
      },
    )
      ..selectMode(CustomerAuthenticationMode.signUp)
      ..changeFullName('Maria da Silva')
      ..changePhoneNumber('51999991234')
      ..changeEmailAddress('maria@example.com')
      ..changePassword('senha-segura-123')
      ..changePasswordConfirmation('senha-segura-123')
      ..changeLegalTermsAccepted(true);

    expect(await controller.signUp(), isFalse);
    expect(controller.state.errorMessage, contains('criar a conta'));
  });
}
