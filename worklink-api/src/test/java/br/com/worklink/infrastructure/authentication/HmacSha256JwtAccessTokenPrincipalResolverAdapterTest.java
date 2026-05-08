package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.IssuedAccessToken;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class HmacSha256JwtAccessTokenPrincipalResolverAdapterTest {

    private static final String JWT_SECRET = "test-secret-with-enough-size";
    private static final Instant ISSUED_AT = Instant.parse("2026-05-08T20:00:00Z");
    private static final UUID PRINCIPAL_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("GIVEN access token assinado WHEN resolver principal THEN deve retornar perfil autenticado")
    void givenSignedAccessTokenWhenResolvePrincipalThenShouldReturnAuthenticatedProfile() {
        // GIVEN
        HmacSha256JwtAccessTokenIssuerAdapter issuerAdapter = new HmacSha256JwtAccessTokenIssuerAdapter(JWT_SECRET, 15);
        IssuedAccessToken issuedAccessToken = issuerAdapter.issueAccessToken(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.ADMINISTRATOR.name(),
                ISSUED_AT
        );
        HmacSha256JwtAccessTokenPrincipalResolverAdapter resolverAdapter = resolverAt(ISSUED_AT.plusSeconds(60));

        // WHEN
        Optional<AuthenticatedPrincipal> authenticatedPrincipal = resolverAdapter.resolveAuthenticatedPrincipal(
                issuedAccessToken.accessToken()
        );

        // THEN
        assertThat(authenticatedPrincipal).contains(new AuthenticatedPrincipal(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.ADMINISTRATOR
        ));
    }

    @Test
    @DisplayName("GIVEN access token adulterado WHEN resolver principal THEN deve rejeitar autenticacao")
    void givenTamperedAccessTokenWhenResolvePrincipalThenShouldRejectAuthentication() {
        // GIVEN
        HmacSha256JwtAccessTokenIssuerAdapter issuerAdapter = new HmacSha256JwtAccessTokenIssuerAdapter(JWT_SECRET, 15);
        IssuedAccessToken issuedAccessToken = issuerAdapter.issueAccessToken(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.CUSTOMER.name(),
                ISSUED_AT
        );
        String tamperedAccessToken = "%sA".formatted(issuedAccessToken.accessToken());
        HmacSha256JwtAccessTokenPrincipalResolverAdapter resolverAdapter = resolverAt(ISSUED_AT.plusSeconds(60));

        // WHEN / THEN
        assertThat(resolverAdapter.resolveAuthenticatedPrincipal(tamperedAccessToken)).isEmpty();
    }

    @Test
    @DisplayName("GIVEN access token expirado WHEN resolver principal THEN deve rejeitar autenticacao")
    void givenExpiredAccessTokenWhenResolvePrincipalThenShouldRejectAuthentication() {
        // GIVEN
        HmacSha256JwtAccessTokenIssuerAdapter issuerAdapter = new HmacSha256JwtAccessTokenIssuerAdapter(JWT_SECRET, 15);
        IssuedAccessToken issuedAccessToken = issuerAdapter.issueAccessToken(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.CUSTOMER.name(),
                ISSUED_AT
        );
        HmacSha256JwtAccessTokenPrincipalResolverAdapter resolverAdapter = resolverAt(ISSUED_AT.plusSeconds(901));

        // WHEN / THEN
        assertThat(resolverAdapter.resolveAuthenticatedPrincipal(issuedAccessToken.accessToken())).isEmpty();
    }

    private HmacSha256JwtAccessTokenPrincipalResolverAdapter resolverAt(Instant currentInstant) {
        CurrentTimePort currentTimePort = () -> currentInstant;
        return new HmacSha256JwtAccessTokenPrincipalResolverAdapter(
                JWT_SECRET,
                new ObjectMapper(),
                currentTimePort
        );
    }
}
