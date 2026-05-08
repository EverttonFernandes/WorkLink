package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.AuthenticationRefreshSession;

public interface UpdateRefreshSessionPort {

    AuthenticationRefreshSession updateRefreshSession(AuthenticationRefreshSession authenticationRefreshSession);
}
