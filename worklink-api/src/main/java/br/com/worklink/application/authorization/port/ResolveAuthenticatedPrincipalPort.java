package br.com.worklink.application.authorization.port;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.Optional;

public interface ResolveAuthenticatedPrincipalPort {

    Optional<AuthenticatedPrincipal> resolveAuthenticatedPrincipal(String accessToken);
}
