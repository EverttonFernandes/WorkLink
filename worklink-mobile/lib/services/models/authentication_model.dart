// ignore_for_file: sort_constructors_first

class AuthenticationOtpRequestResult {
  const AuthenticationOtpRequestResult({
    required this.message,
    required this.expiresAt,
  });

  final String message;
  final DateTime expiresAt;

  factory AuthenticationOtpRequestResult.fromJson(Map<String, dynamic> json) {
    return AuthenticationOtpRequestResult(
      message: json['message']?.toString() ?? '',
      expiresAt: DateTime.parse(json['expiresAt'].toString()),
    );
  }
}

class AuthenticationSession {
  const AuthenticationSession({
    required this.customerIdentifier,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  final String customerIdentifier;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;

  factory AuthenticationSession.fromJson(Map<String, dynamic> json) {
    return AuthenticationSession(
      customerIdentifier: json['customerIdentifier']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      accessTokenExpiresAt:
          DateTime.parse(json['accessTokenExpiresAt'].toString()),
      refreshTokenExpiresAt:
          DateTime.parse(json['refreshTokenExpiresAt'].toString()),
    );
  }
}
