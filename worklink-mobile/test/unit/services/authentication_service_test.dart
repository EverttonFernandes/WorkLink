import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/authentication_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;
  late AuthenticationService authenticationService;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
    authenticationService = AuthenticationService(httpClient: httpClient);
  });

  test(
      'GIVEN telefone valido WHEN solicitar OTP THEN deve chamar endpoint correto',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/authentication/otp/request'] = {
      'message': 'Codigo enviado.',
      'expiresAt': '2026-05-13T10:00:00Z',
      'deliveryChannels': ['SMS', 'WHATSAPP', 'EMAIL'],
      'simulatedDelivery': true,
    };

    // WHEN
    final result = await authenticationService.requestAuthenticationOtp(
      '+5551999999999',
      deliveryChannel: 'WHATSAPP',
    );

    // THEN
    expect(result.message, 'Codigo enviado.');
    expect(result.deliveryChannels, ['SMS', 'WHATSAPP', 'EMAIL']);
    expect(result.simulatedDelivery, isTrue);
    expect(httpClient.requests.single.method, 'POST');
    expect(
      httpClient.requests.single.path,
      '/api/v1/authentication/otp/request',
    );
    expect(
      httpClient.requests.single.data,
      {
        'phoneNumber': '+5551999999999',
        'deliveryChannel': 'WHATSAPP',
      },
    );
  });

  test(
      'GIVEN OTP valido WHEN verificar codigo THEN deve armazenar Bearer token',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/authentication/otp/verify'] = {
      'customerIdentifier': 'customer-1',
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'accessTokenExpiresAt': '2026-05-13T10:15:00Z',
      'refreshTokenExpiresAt': '2026-06-13T10:00:00Z',
    };

    // WHEN
    final session = await authenticationService.verifyAuthenticationOtp(
      phoneNumber: '+5551999999999',
      oneTimePassword: '123456',
    );

    // THEN
    expect(session.customerIdentifier, 'customer-1');
    expect(httpClient.bearerTokens.single, 'access-token');
    expect(httpClient.requests.single.data, {
      'phoneNumber': '+5551999999999',
      'oneTimePassword': '123456',
    });
  });

  test(
      'GIVEN refresh token valido WHEN renovar sessao THEN deve trocar Bearer token',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/authentication/session/refresh'] = {
      'customerIdentifier': 'customer-1',
      'accessToken': 'new-access-token',
      'refreshToken': 'new-refresh-token',
      'accessTokenExpiresAt': '2026-05-13T10:15:00Z',
      'refreshTokenExpiresAt': '2026-06-13T10:00:00Z',
    };

    // WHEN
    final session = await authenticationService.refreshAuthenticationSession(
      'refresh-token',
    );

    // THEN
    expect(session.accessToken, 'new-access-token');
    expect(httpClient.bearerTokens.single, 'new-access-token');
    expect(
      httpClient.requests.single.path,
      '/api/v1/authentication/session/refresh',
    );
  });

  test(
      'GIVEN sessao ativa WHEN revogar refresh token THEN deve limpar autenticacao',
      () async {
    // WHEN
    await authenticationService.revokeAuthenticationSession('refresh-token');

    // THEN
    expect(
      httpClient.requests.single.path,
      '/api/v1/authentication/session/revoke',
    );
    expect(httpClient.bearerTokens.single, isNull);
  });
}
