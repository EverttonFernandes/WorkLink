package br.com.worklink.api.authorization;

import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.authorization.usecase.ResolveAuthenticatedPrincipalUseCase;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AuthenticatedPrincipalHttpResolverTest {

    private static final UUID PRINCIPAL_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("GIVEN header bearer valido WHEN resolver principal HTTP THEN deve retornar principal autenticado")
    void givenValidBearerHeaderWhenResolveHttpPrincipalThenShouldReturnAuthenticatedPrincipal() {
        // GIVEN
        AuthenticatedPrincipal expectedAuthenticatedPrincipal = new AuthenticatedPrincipal(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.CUSTOMER
        );
        ResolveAuthenticatedPrincipalUseCase useCase = new ResolveAuthenticatedPrincipalUseCase(
                accessToken -> Optional.of(expectedAuthenticatedPrincipal)
        );
        AuthenticatedPrincipalHttpResolver resolver = new AuthenticatedPrincipalHttpResolver(useCase);

        // WHEN
        AuthenticatedPrincipal authenticatedPrincipal = resolver.resolveAuthenticatedPrincipal("Bearer access-token");

        // THEN
        assertThat(authenticatedPrincipal).isEqualTo(expectedAuthenticatedPrincipal);
    }

    @Test
    @DisplayName("GIVEN header sem bearer WHEN resolver principal HTTP THEN deve exigir autenticacao")
    void givenHeaderWithoutBearerWhenResolveHttpPrincipalThenShouldRequireAuthentication() {
        // GIVEN
        AuthenticatedPrincipalHttpResolver resolver = new AuthenticatedPrincipalHttpResolver(
                new ResolveAuthenticatedPrincipalUseCase(accessToken -> Optional.empty())
        );

        // WHEN / THEN
        assertThatThrownBy(() -> resolver.resolveAuthenticatedPrincipal("access-token"))
                .isInstanceOf(AuthenticationRequiredException.class)
                .hasMessage("Autenticacao obrigatoria para este recurso.");
    }

    @Test
    @DisplayName("GIVEN header ausente WHEN resolver principal HTTP THEN deve exigir autenticacao")
    void givenMissingHeaderWhenResolveHttpPrincipalThenShouldRequireAuthentication() {
        // GIVEN
        AuthenticatedPrincipalHttpResolver resolver = new AuthenticatedPrincipalHttpResolver(
                new ResolveAuthenticatedPrincipalUseCase(accessToken -> Optional.empty())
        );

        // WHEN / THEN
        assertThatThrownBy(() -> resolver.resolveAuthenticatedPrincipal(null))
                .isInstanceOf(AuthenticationRequiredException.class)
                .hasMessage("Autenticacao obrigatoria para este recurso.");
    }
}
