import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/authentication_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;
  late AuthenticationService service;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
    service = AuthenticationService(httpClient: httpClient);
  });

  Map<String, dynamic> sessionJson() => {
        'principalIdentifier': 'customer-1',
        'profile': 'CUSTOMER',
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'accessTokenExpiresAt': '2026-06-11T10:15:00Z',
        'refreshTokenExpiresAt': '2026-07-11T10:00:00Z',
      };

  test(
      'GIVEN cadastro local WHEN registrar THEN deve usar contrato REST e Bearer',
      () async {
    httpClient.objectResponses['/api/v1/authentication/register'] =
        sessionJson();

    final session = await service.registerLocalAccount(
      fullName: 'Maria da Silva',
      phoneNumber: '51999991234',
      emailAddress: 'maria@exemplo.com',
      password: 'senha-segura-123',
      passwordConfirmation: 'senha-segura-123',
      legalTermsAccepted: true,
    );

    expect(session.principalIdentifier, 'customer-1');
    expect(httpClient.requests.single.path, '/api/v1/authentication/register');
    expect(httpClient.requests.single.data, {
      'fullName': 'Maria da Silva',
      'phoneNumber': '51999991234',
      'emailAddress': 'maria@exemplo.com',
      'password': 'senha-segura-123',
      'passwordConfirmation': 'senha-segura-123',
      'legalTermsAccepted': true,
    });
    expect(httpClient.bearerTokens, ['access-token']);
  });

  test('GIVEN credenciais WHEN entrar THEN deve usar login local', () async {
    httpClient.objectResponses['/api/v1/authentication/login'] = sessionJson();

    await service.authenticateWithEmailAndPassword(
      emailAddress: 'cliente@exemplo.com',
      password: 'senha-segura-123',
    );

    expect(httpClient.requests.single.path, '/api/v1/authentication/login');
    expect(httpClient.requests.single.data, {
      'emailAddress': 'cliente@exemplo.com',
      'password': 'senha-segura-123',
    });
  });

  test('GIVEN email WHEN solicitar recuperacao THEN deve usar resposta vazia',
      () async {
    await service.requestPasswordRecovery('cliente@exemplo.com');

    expect(
      httpClient.requests.single.path,
      '/api/v1/authentication/password-recovery/request',
    );
    expect(httpClient.requests.single.data, {
      'emailAddress': 'cliente@exemplo.com',
    });
  });

  test('GIVEN token WHEN redefinir senha THEN deve enviar confirmacao',
      () async {
    await service.resetPassword(
      recoveryToken: 'ABC123',
      newPassword: 'nova-senha-segura',
      newPasswordConfirmation: 'nova-senha-segura',
    );

    expect(
      httpClient.requests.single.path,
      '/api/v1/authentication/password-recovery/reset',
    );
    expect(httpClient.requests.single.data, {
      'recoveryToken': 'ABC123',
      'newPassword': 'nova-senha-segura',
      'newPasswordConfirmation': 'nova-senha-segura',
    });
    expect(httpClient.bearerTokens, [null]);
  });

  test('GIVEN resposta legada WHEN mapear sessao THEN deve aceitar customer id',
      () async {
    httpClient.objectResponses['/api/v1/authentication/login'] = {
      ...sessionJson(),
      'principalIdentifier': null,
      'customerIdentifier': 'legacy-customer',
    };

    final session = await service.authenticateWithEmailAndPassword(
      emailAddress: 'cliente@exemplo.com',
      password: 'senha-segura-123',
    );

    expect(session.principalIdentifier, 'legacy-customer');
  });

  test('GIVEN canal OTP futuro WHEN solicitar e validar THEN deve preservar contrato',
      () async {
    httpClient.objectResponses['/api/v1/authentication/otp/request'] = {
      'message': 'Mensagem generica',
      'expiresAt': '2026-06-11T10:05:00Z',
      'deliveryChannels': ['SMS'],
      'simulatedDelivery': true,
    };
    httpClient.objectResponses['/api/v1/authentication/otp/verify'] =
        sessionJson();

    final requestResult = await service.requestAuthenticationOtp(
      '51999991234',
      deliveryChannel: 'SMS',
      emailAddress: 'cliente@example.com',
    );
    final session = await service.verifyAuthenticationOtp(
      phoneNumber: '51999991234',
      oneTimePassword: '123456',
    );

    expect(requestResult.deliveryChannels, ['SMS']);
    expect(session.principalIdentifier, 'customer-1');
    expect(httpClient.bearerTokens, ['access-token']);
  });

  test('GIVEN refresh e logout WHEN operar sessao THEN deve atualizar Bearer',
      () async {
    httpClient.objectResponses['/api/v1/authentication/session/refresh'] =
        sessionJson();

    final session =
        await service.refreshAuthenticationSession('refresh-token-antigo');
    await service.revokeAuthenticationSession(session.refreshToken);

    expect(
      httpClient.requests.map((request) => request.path),
      [
        '/api/v1/authentication/session/refresh',
        '/api/v1/authentication/session/revoke',
      ],
    );
    expect(httpClient.bearerTokens, ['access-token', null]);
  });
}
