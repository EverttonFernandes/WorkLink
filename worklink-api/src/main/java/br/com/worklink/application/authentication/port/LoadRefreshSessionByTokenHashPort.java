package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.AuthenticationRefreshSession;

import java.util.Optional;

public interface LoadRefreshSessionByTokenHashPort {

    Optional<AuthenticationRefreshSession> loadRefreshSessionByTokenHash(String refreshTokenHash);
}
