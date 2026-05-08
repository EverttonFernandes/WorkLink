package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.AuthenticationRefreshSession;

public interface SaveRefreshSessionPort {

    AuthenticationRefreshSession saveRefreshSession(AuthenticationRefreshSession authenticationRefreshSession);
}
