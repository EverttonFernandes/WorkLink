import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationSessionRefreshCredentials {
  const AuthenticationSessionRefreshCredentials({
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
}

abstract interface class AuthenticationSessionStore {
  Future<AuthenticationSessionRefreshCredentials?>
      loadAuthenticationSessionRefreshCredentials();

  Future<void> persistAuthenticationSessionRefreshCredentials(
    AuthenticationSessionRefreshCredentials refreshCredentials,
  );

  Future<void> clearAuthenticationSession();
}

class FlutterSecureAuthenticationSessionStore
    implements AuthenticationSessionStore {
  FlutterSecureAuthenticationSessionStore({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _refreshCredentialsStorageKey =
      'worklink.authentication.refresh-credentials';
  static const _refreshTokenJsonKey = 'refreshToken';
  static const _refreshTokenExpiresAtJsonKey = 'refreshTokenExpiresAt';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<AuthenticationSessionRefreshCredentials?>
      loadAuthenticationSessionRefreshCredentials() async {
    final serializedRefreshCredentials = await _secureStorage.read(
      key: _refreshCredentialsStorageKey,
    );
    if (serializedRefreshCredentials == null ||
        serializedRefreshCredentials.isEmpty) {
      return null;
    }

    try {
      final decodedRefreshCredentials = jsonDecode(
        serializedRefreshCredentials,
      );
      if (decodedRefreshCredentials is! Map<String, dynamic>) {
        await clearAuthenticationSession();
        return null;
      }
      final refreshToken =
          decodedRefreshCredentials[_refreshTokenJsonKey]?.toString() ?? '';
      final refreshTokenExpiresAt = DateTime.tryParse(
        decodedRefreshCredentials[_refreshTokenExpiresAtJsonKey]?.toString() ??
            '',
      );
      if (refreshToken.isEmpty || refreshTokenExpiresAt == null) {
        await clearAuthenticationSession();
        return null;
      }
      return AuthenticationSessionRefreshCredentials(
        refreshToken: refreshToken,
        refreshTokenExpiresAt: refreshTokenExpiresAt,
      );
    } on FormatException {
      await clearAuthenticationSession();
      return null;
    }
  }

  @override
  Future<void> persistAuthenticationSessionRefreshCredentials(
    AuthenticationSessionRefreshCredentials refreshCredentials,
  ) async {
    await _secureStorage.write(
      key: _refreshCredentialsStorageKey,
      value: jsonEncode({
        _refreshTokenJsonKey: refreshCredentials.refreshToken,
        _refreshTokenExpiresAtJsonKey:
            refreshCredentials.refreshTokenExpiresAt.toIso8601String(),
      }),
    );
  }

  @override
  Future<void> clearAuthenticationSession() async {
    await _secureStorage.delete(key: _refreshCredentialsStorageKey);
  }
}
