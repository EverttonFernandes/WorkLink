package br.com.worklink.application.authorization.usecase;

import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.authorization.port.ResolveAuthenticatedPrincipalPort;

public class ResolveAuthenticatedPrincipalUseCase {

    private static final String UNAUTHENTICATED_MESSAGE = "Autenticacao obrigatoria para este recurso.";

    private final ResolveAuthenticatedPrincipalPort resolveAuthenticatedPrincipalPort;

    public ResolveAuthenticatedPrincipalUseCase(ResolveAuthenticatedPrincipalPort resolveAuthenticatedPrincipalPort) {
        this.resolveAuthenticatedPrincipalPort = resolveAuthenticatedPrincipalPort;
    }

    public AuthenticatedPrincipal resolveAuthenticatedPrincipal(String accessToken) {
        if (accessToken == null || accessToken.isBlank()) {
            throw new AuthenticationRequiredException(UNAUTHENTICATED_MESSAGE);
        }
        return resolveAuthenticatedPrincipalPort.resolveAuthenticatedPrincipal(accessToken)
                .orElseThrow(() -> new AuthenticationRequiredException(UNAUTHENTICATED_MESSAGE));
    }
}
