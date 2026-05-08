package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.IssuedAccessToken;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.AuthenticationRefreshSession;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

class AuthenticationSessionTokenFactory {

    private static final String CUSTOMER_PROFILE = "CUSTOMER";

    private final IssueAccessTokenPort issueAccessTokenPort;
    private final GenerateSecureTokenPort generateSecureTokenPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final SaveRefreshSessionPort saveRefreshSessionPort;
    private final Duration refreshTokenDuration;

    AuthenticationSessionTokenFactory(
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            Duration refreshTokenDuration
    ) {
        this.issueAccessTokenPort = issueAccessTokenPort;
        this.generateSecureTokenPort = generateSecureTokenPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.saveRefreshSessionPort = saveRefreshSessionPort;
        this.refreshTokenDuration = refreshTokenDuration;
    }

    AuthenticationTokenResponse createTokenResponse(UUID customerIdentifier, Instant currentInstant) {
        IssuedAccessToken issuedAccessToken = issueAccessTokenPort.issueAccessToken(
                customerIdentifier,
                CUSTOMER_PROFILE,
                currentInstant
        );
        String refreshToken = generateSecureTokenPort.generateSecureToken();
        String refreshTokenHash = protectSensitiveValuePort.protectSensitiveValue(
                refreshToken,
                ProtectedSensitiveValuePurpose.REFRESH_TOKEN
        );
        Instant refreshTokenExpiresAt = currentInstant.plus(refreshTokenDuration);
        saveRefreshSessionPort.saveRefreshSession(AuthenticationRefreshSession.startSession(
                customerIdentifier,
                refreshTokenHash,
                refreshTokenExpiresAt,
                currentInstant
        ));
        return new AuthenticationTokenResponse(
                customerIdentifier,
                issuedAccessToken.accessToken(),
                refreshToken,
                issuedAccessToken.expiresAt(),
                refreshTokenExpiresAt
        );
    }
}
