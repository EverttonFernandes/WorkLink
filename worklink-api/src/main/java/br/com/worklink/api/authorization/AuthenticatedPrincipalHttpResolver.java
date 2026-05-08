package br.com.worklink.api.authorization;

import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.ResolveAuthenticatedPrincipalUseCase;

import org.springframework.stereotype.Component;

@Component
public class AuthenticatedPrincipalHttpResolver {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final String UNAUTHENTICATED_MESSAGE = "Autenticacao obrigatoria para este recurso.";

    private final ResolveAuthenticatedPrincipalUseCase resolveAuthenticatedPrincipalUseCase;

    public AuthenticatedPrincipalHttpResolver(ResolveAuthenticatedPrincipalUseCase resolveAuthenticatedPrincipalUseCase) {
        this.resolveAuthenticatedPrincipalUseCase = resolveAuthenticatedPrincipalUseCase;
    }

    public AuthenticatedPrincipal resolveAuthenticatedPrincipal(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith(BEARER_PREFIX)) {
            throw new AuthenticationRequiredException(UNAUTHENTICATED_MESSAGE);
        }
        String accessToken = authorizationHeader.substring(BEARER_PREFIX.length()).trim();
        return resolveAuthenticatedPrincipalUseCase.resolveAuthenticatedPrincipal(accessToken);
    }
}
