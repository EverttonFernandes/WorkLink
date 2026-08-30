// ignore_for_file: sort_constructors_first

class AuthenticationOtpRequestResult {
  const AuthenticationOtpRequestResult({
    required this.message,
    required this.expiresAt,
    required this.deliveryChannels,
    required this.simulatedDelivery,
  });

  final String message;
  final DateTime expiresAt;
  final List<String> deliveryChannels;
  final bool simulatedDelivery;

  factory AuthenticationOtpRequestResult.fromJson(Map<String, dynamic> json) {
    return AuthenticationOtpRequestResult(
      message: json['message']?.toString() ?? '',
      expiresAt: DateTime.parse(json['expiresAt'].toString()),
      deliveryChannels: (json['deliveryChannels'] as List<dynamic>? ?? const [])
          .map((channel) => channel.toString())
          .toList(),
      simulatedDelivery: json['simulatedDelivery'] == true,
    );
  }
}

class AuthenticationSession {
  const AuthenticationSession({
    required this.principalIdentifier,
    required this.profile,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  final String principalIdentifier;
  final String profile;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;

  String get customerIdentifier => principalIdentifier;

  Map<String, dynamic> toJson() {
    return {
      'principalIdentifier': principalIdentifier,
      'profile': profile,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
    };
  }

  factory AuthenticationSession.fromJson(Map<String, dynamic> json) {
    return AuthenticationSession(
      principalIdentifier: json['principalIdentifier']?.toString() ??
          json['customerIdentifier']?.toString() ??
          '',
      profile: json['profile']?.toString() ?? 'CUSTOMER',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      accessTokenExpiresAt:
          DateTime.parse(json['accessTokenExpiresAt'].toString()),
      refreshTokenExpiresAt:
          DateTime.parse(json['refreshTokenExpiresAt'].toString()),
    );
  }
}
