package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;

public class RevokeAuthenticationSessionUseCase {

    private final LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort;
    private final UpdateRefreshSessionPort updateRefreshSessionPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;

    public RevokeAuthenticationSessionUseCase(
            LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort,
            UpdateRefreshSessionPort updateRefreshSessionPort,
            ProtectSensitiveValuePort protectSensitiveValuePort
    ) {
        this.loadRefreshSessionByTokenHashPort = loadRefreshSessionByTokenHashPort;
        this.updateRefreshSessionPort = updateRefreshSessionPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
    }

    public void revokeAuthenticationSession(RevokeAuthenticationSessionRequest request) {
        String refreshTokenHash = protectSensitiveValuePort.protectSensitiveValue(
                request.refreshToken(),
                ProtectedSensitiveValuePurpose.REFRESH_TOKEN
        );
        loadRefreshSessionByTokenHashPort.loadRefreshSessionByTokenHash(refreshTokenHash)
                .filter(refreshSession -> !refreshSession.revoked())
                .ifPresent(refreshSession -> updateRefreshSessionPort.updateRefreshSession(refreshSession.revoke()));
    }
}
