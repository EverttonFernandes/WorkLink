import 'api_client.dart';
import 'models/authentication_model.dart';

class AuthenticationService {
  const AuthenticationService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<AuthenticationSession> registerLocalAccount({
    required String fullName,
    required String phoneNumber,
    required String emailAddress,
    required String password,
    required String passwordConfirmation,
    required bool legalTermsAccepted,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/authentication/register',
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'emailAddress': emailAddress,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
        'legalTermsAccepted': legalTermsAccepted,
      },
    );
    return _activateSession(response);
  }

  Future<AuthenticationSession> authenticateWithEmailAndPassword({
    required String emailAddress,
    required String password,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/authentication/login',
      data: {
        'emailAddress': emailAddress,
        'password': password,
      },
    );
    return _activateSession(response);
  }

  Future<void> requestPasswordRecovery(String emailAddress) async {
    await _httpClient.postEmpty(
      '/api/v1/authentication/password-recovery/request',
      data: {'emailAddress': emailAddress},
    );
  }

  Future<void> resetPassword({
    required String recoveryToken,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _httpClient.postEmpty(
      '/api/v1/authentication/password-recovery/reset',
      data: {
        'recoveryToken': recoveryToken,
        'newPassword': newPassword,
        'newPasswordConfirmation': newPasswordConfirmation,
      },
    );
    _httpClient.clearBearerToken();
  }

  Future<AuthenticationOtpRequestResult> requestAuthenticationOtp(
    String phoneNumber, {
    required String deliveryChannel,
    String? emailAddress,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/authentication/otp/request',
      data: {
        'phoneNumber': phoneNumber,
        'deliveryChannel': deliveryChannel,
        if (emailAddress != null) 'emailAddress': emailAddress,
      },
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
    return _activateSession(response);
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

  AuthenticationSession _activateSession(Map<String, dynamic> response) {
    final session = AuthenticationSession.fromJson(response);
    _httpClient.setBearerToken(session.accessToken);
    return session;
  }
}
