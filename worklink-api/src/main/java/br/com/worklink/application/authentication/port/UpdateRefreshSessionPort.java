package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.AuthenticationRefreshSession;

@FunctionalInterface
public interface UpdateRefreshSessionPort {

    AuthenticationRefreshSession updateRefreshSession(AuthenticationRefreshSession authenticationRefreshSession);

    default boolean revokeRefreshSessionIfActive(AuthenticationRefreshSession authenticationRefreshSession) {
        updateRefreshSession(authenticationRefreshSession.revoke());
        return true;
    }
}
