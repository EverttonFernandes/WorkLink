import 'api_client.dart';
import 'models/authentication_model.dart';

class AuthenticationService {
  const AuthenticationService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<AuthenticationOtpRequestResult> requestAuthenticationOtp(
    String phoneNumber,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/authentication/otp/request',
      data: {'phoneNumber': phoneNumber},
    );
    return AuthenticationOtpRequestResult.fromJson(response);
  }

  Future<AuthenticationSession> verifyAuthenticationOtp({
    required String phoneNumber,
    required String oneTimePassword,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/authentication/otp/verify',
      data: {
        'phoneNumber': phoneNumber,
        'oneTimePassword': oneTimePassword,
      },
    );
    final session = AuthenticationSession.fromJson(response);
    _httpClient.setBearerToken(session.accessToken);
    return session;
  }

  Future<AuthenticationSession> refreshAuthenticationSession(
    String refreshToken,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/authentication/session/refresh',
      data: {'refreshToken': refreshToken},
    );
    final session = AuthenticationSession.fromJson(response);
    _httpClient.setBearerToken(session.accessToken);
    return session;
  }

  Future<void> revokeAuthenticationSession(String refreshToken) async {
    await _httpClient.postEmpty(
      '/api/v1/authentication/session/revoke',
      data: {'refreshToken': refreshToken},
    );
    _httpClient.clearBearerToken();
  }
}
