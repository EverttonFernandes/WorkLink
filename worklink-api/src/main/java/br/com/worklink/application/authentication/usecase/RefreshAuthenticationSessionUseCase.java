package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.InvalidAuthenticationCredentialsException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.AuthenticationRefreshSession;

import java.time.Duration;
import java.time.Instant;

public class RefreshAuthenticationSessionUseCase {

    private static final String GENERIC_SESSION_FAILURE = "Nao foi possivel renovar a sessao.";

    private final LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort;
    private final UpdateRefreshSessionPort updateRefreshSessionPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final CurrentTimePort currentTimePort;
    private final ExecuteInTransactionPort executeInTransactionPort;
    private final AuthenticationSessionTokenFactory authenticationSessionTokenFactory;

    public RefreshAuthenticationSessionUseCase(
            LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort,
            UpdateRefreshSessionPort updateRefreshSessionPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            CurrentTimePort currentTimePort,
            ExecuteInTransactionPort executeInTransactionPort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            Duration refreshTokenDuration
    ) {
        this.loadRefreshSessionByTokenHashPort = loadRefreshSessionByTokenHashPort;
        this.updateRefreshSessionPort = updateRefreshSessionPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.currentTimePort = currentTimePort;
        this.executeInTransactionPort = executeInTransactionPort;
        this.authenticationSessionTokenFactory = new AuthenticationSessionTokenFactory(
                issueAccessTokenPort,
                generateSecureTokenPort,
                protectSensitiveValuePort,
                saveRefreshSessionPort,
                refreshTokenDuration
        );
    }

    public AuthenticationTokenResponse refreshAuthenticationSession(RefreshAuthenticationSessionRequest request) {
        return executeInTransactionPort.execute(() -> {
            Instant currentInstant = currentTimePort.currentInstant();
            String refreshTokenHash = protectSensitiveValuePort.protectSensitiveValue(
                    request.refreshToken(),
                    ProtectedSensitiveValuePurpose.REFRESH_TOKEN
            );
            AuthenticationRefreshSession refreshSession = loadRefreshSessionByTokenHashPort
                    .loadRefreshSessionByTokenHash(refreshTokenHash)
                    .orElseThrow(() -> new InvalidAuthenticationCredentialsException(GENERIC_SESSION_FAILURE));

            if (refreshSession.revoked() || refreshSession.isExpiredAt(currentInstant)) {
                throw new InvalidAuthenticationCredentialsException(GENERIC_SESSION_FAILURE);
            }
            if (!updateRefreshSessionPort.revokeRefreshSessionIfActive(refreshSession)) {
                throw new InvalidAuthenticationCredentialsException(GENERIC_SESSION_FAILURE);
            }
            return authenticationSessionTokenFactory.createTokenResponse(
                    refreshSession.customerIdentifier(), currentInstant
            );
        });
    }
}
