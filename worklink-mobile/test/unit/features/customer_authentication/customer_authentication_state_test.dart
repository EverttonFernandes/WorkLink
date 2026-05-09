import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';

void main() {
  test('GIVEN telefone celular WHEN exibir telefone THEN deve formatar com nono digito', () {
    // GIVEN
    const customerAuthenticationState = CustomerAuthenticationState(
      phoneNumber: '(51) 9 9999-1234',
      normalizedPhoneNumber: '51999991234',
    );

    // WHEN / THEN
    expect(customerAuthenticationState.displayPhoneNumber, '(51) 9 9999-1234');
  });

  test('GIVEN telefone fixo WHEN exibir telefone THEN deve formatar sem nono digito', () {
    // GIVEN
    const customerAuthenticationState = CustomerAuthenticationState(
      phoneNumber: '(51) 3333-1234',
      normalizedPhoneNumber: '5133331234',
    );

    // WHEN / THEN
    expect(customerAuthenticationState.displayPhoneNumber, '(51) 3333-1234');
  });

  test('GIVEN telefone incompleto WHEN exibir telefone THEN deve preservar texto informado', () {
    // GIVEN
    const customerAuthenticationState = CustomerAuthenticationState(
      phoneNumber: '51',
      normalizedPhoneNumber: '51',
    );

    // WHEN / THEN
    expect(customerAuthenticationState.displayPhoneNumber, '51');
  });

  test('GIVEN codigo com quatro digitos WHEN consultar confirmacao THEN deve permitir confirmar', () {
    // GIVEN
    const customerAuthenticationState = CustomerAuthenticationState(
      verificationCode: '1234',
    );

    // WHEN / THEN
    expect(customerAuthenticationState.canConfirmVerificationCode, isTrue);
  });

  test('GIVEN estado com mensagens WHEN copiar limpando mensagens THEN deve remover feedback anterior', () {
    // GIVEN
    const customerAuthenticationState = CustomerAuthenticationState(
      errorMessage: 'erro',
      statusMessage: 'status',
    );

    // WHEN
    final updatedState = customerAuthenticationState.copyWith(
      clearErrorMessage: true,
      clearStatusMessage: true,
    );

    // THEN
    expect(updatedState.errorMessage, isNull);
    expect(updatedState.statusMessage, isNull);
  });
}
