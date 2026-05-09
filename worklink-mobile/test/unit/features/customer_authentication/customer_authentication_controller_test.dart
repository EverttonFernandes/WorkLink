import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_controller.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';

void main() {
  test(
      'GIVEN telefone valido WHEN solicitar codigo THEN deve abrir verificacao sem autenticar',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();

    // WHEN
    customerAuthenticationController.changePhoneNumber('(51) 9 9999-1234');
    final requestAccepted =
        customerAuthenticationController.requestVerificationCode();

    // THEN
    expect(requestAccepted, isTrue);
    expect(
      customerAuthenticationController.state.authenticationStep,
      CustomerAuthenticationStep.codeVerification,
    );
    expect(
      customerAuthenticationController.state.normalizedPhoneNumber,
      '51999991234',
    );
    expect(customerAuthenticationController.state.authenticated, isFalse);
  });

  test(
      'GIVEN telefone com codigo do pais WHEN solicitar codigo THEN deve autenticar telefone nacional',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();

    // WHEN
    customerAuthenticationController.changePhoneNumber('+55 (51) 9 9999-1234');
    final requestAccepted =
        customerAuthenticationController.requestVerificationCode();

    // THEN
    expect(requestAccepted, isTrue);
    expect(
      customerAuthenticationController.state.normalizedPhoneNumber,
      '51999991234',
    );
  });

  test(
      'GIVEN telefone invalido WHEN solicitar codigo THEN deve permanecer na entrada de telefone',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();

    // WHEN
    customerAuthenticationController.changePhoneNumber('51');
    final requestAccepted =
        customerAuthenticationController.requestVerificationCode();

    // THEN
    expect(requestAccepted, isFalse);
    expect(
      customerAuthenticationController.state.authenticationStep,
      CustomerAuthenticationStep.phoneEntry,
    );
    expect(
      customerAuthenticationController.state.errorMessage,
      'Informe um telefone valido.',
    );
  });

  test(
      'GIVEN codigo correto WHEN confirmar verificacao THEN deve autenticar cliente',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    customerAuthenticationController.changePhoneNumber('51999991234');
    customerAuthenticationController.requestVerificationCode();

    // WHEN
    customerAuthenticationController.changeVerificationCode('1234');
    final verificationAccepted =
        customerAuthenticationController.confirmVerificationCode();

    // THEN
    expect(verificationAccepted, isTrue);
    expect(customerAuthenticationController.state.authenticated, isTrue);
    expect(
      customerAuthenticationController.state.authenticationStep,
      CustomerAuthenticationStep.authenticated,
    );
  });

  test(
      'GIVEN codigo incorreto WHEN confirmar verificacao THEN deve exibir mensagem generica',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    customerAuthenticationController.changePhoneNumber('51999991234');
    customerAuthenticationController.requestVerificationCode();

    // WHEN
    customerAuthenticationController.changeVerificationCode('0000');
    final verificationAccepted =
        customerAuthenticationController.confirmVerificationCode();

    // THEN
    expect(verificationAccepted, isFalse);
    expect(customerAuthenticationController.state.authenticated, isFalse);
    expect(
      customerAuthenticationController.state.errorMessage,
      'Nao foi possivel concluir a autenticacao.',
    );
  });

  test(
      'GIVEN telefone em verificacao WHEN reenviar codigo THEN deve limpar codigo e manter telefone',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    customerAuthenticationController.changePhoneNumber('51999991234');
    customerAuthenticationController.requestVerificationCode();
    customerAuthenticationController.changeVerificationCode('12');

    // WHEN
    customerAuthenticationController.resendVerificationCode();

    // THEN
    expect(customerAuthenticationController.state.verificationCode, isEmpty);
    expect(customerAuthenticationController.state.resendCount, 1);
    expect(
      customerAuthenticationController.state.normalizedPhoneNumber,
      '51999991234',
    );
  });

  test(
      'GIVEN entrada de telefone WHEN reenviar codigo THEN deve ignorar solicitacao fora da verificacao',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    customerAuthenticationController.changePhoneNumber('51999991234');

    // WHEN
    customerAuthenticationController.resendVerificationCode();

    // THEN
    expect(customerAuthenticationController.state.resendCount, 0);
    expect(
      customerAuthenticationController.state.authenticationStep,
      CustomerAuthenticationStep.phoneEntry,
    );
  });

  test(
      'GIVEN telefone em verificacao WHEN editar telefone THEN deve voltar para entrada',
      () {
    // GIVEN
    final customerAuthenticationController = CustomerAuthenticationController();
    customerAuthenticationController.changePhoneNumber('51999991234');
    customerAuthenticationController.requestVerificationCode();

    // WHEN
    customerAuthenticationController.editPhoneNumber();

    // THEN
    expect(
      customerAuthenticationController.state.authenticationStep,
      CustomerAuthenticationStep.phoneEntry,
    );
    expect(customerAuthenticationController.state.verificationCode, isEmpty);
  });
}
