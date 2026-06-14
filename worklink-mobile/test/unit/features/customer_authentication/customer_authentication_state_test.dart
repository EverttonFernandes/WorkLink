import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';

void main() {
  test('GIVEN estado inicial THEN deve abrir login local sem operacao ativa',
      () {
    const state = CustomerAuthenticationState();

    expect(state.mode, CustomerAuthenticationMode.signIn);
    expect(state.operationStatus, CustomerAuthenticationOperationStatus.idle);
    expect(state.passwordObscured, isTrue);
    expect(state.passwordConfirmationObscured, isTrue);
    expect(state.authenticated, isFalse);
  });

  test('GIVEN email com caixa e espacos THEN deve normalizar para autenticacao',
      () {
    const state = CustomerAuthenticationState(
      emailAddress: ' Cliente@Exemplo.COM ',
    );

    expect(state.normalizedEmailAddress, 'cliente@exemplo.com');
  });

  test('GIVEN telefone informado THEN deve expor como nao verificado', () {
    const state = CustomerAuthenticationState(
      phoneNumber: '(51) 9 9999-1234',
    );

    expect(state.phoneVerificationLabel, 'Celular não verificado');
  });

  test(
      'GIVEN mensagens antigas WHEN alterar campo THEN deve permitir limpa-las',
      () {
    const state = CustomerAuthenticationState(
      errorMessage: 'erro',
      statusMessage: 'status',
    );

    final updated = state.copyWith(
      clearErrorMessage: true,
      clearStatusMessage: true,
    );

    expect(updated.errorMessage, isNull);
    expect(updated.statusMessage, isNull);
  });
}
