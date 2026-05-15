package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.IssuedAccessToken;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class AuthenticationInfrastructureAdapterTest {

    @Test
    @DisplayName("GIVEN gerador OTP WHEN gerar codigo THEN deve retornar seis digitos")
    void shouldGenerateSixDigitOneTimePassword() {
        // GIVEN
        SecureRandomOneTimePasswordGeneratorAdapter adapter =
                new SecureRandomOneTimePasswordGeneratorAdapter(new SecureRandom(new byte[] {1, 2, 3, 4}));

        // WHEN
        String oneTimePassword = adapter.generateOneTimePassword();

        // THEN
        assertThat(oneTimePassword).matches("\\d{6}");
    }

    @Test
    @DisplayName("GIVEN OTP fixo configurado WHEN gerar codigo THEN deve retornar valor deterministico")
    void shouldReturnFixedOneTimePasswordWhenConfigured() {
        // GIVEN
        SecureRandomOneTimePasswordGeneratorAdapter adapter =
                new SecureRandomOneTimePasswordGeneratorAdapter(new SecureRandom(new byte[] {1, 2, 3, 4}), "123456");

        // WHEN
        String oneTimePassword = adapter.generateOneTimePassword();

        // THEN
        assertThat(oneTimePassword).isEqualTo("123456");
    }

    @Test
    @DisplayName("GIVEN gerador token WHEN gerar token THEN deve retornar valor opaco seguro")
    void shouldGenerateOpaqueSecureToken() {
        // GIVEN
        SecureRandomTokenGeneratorAdapter adapter =
                new SecureRandomTokenGeneratorAdapter(new SecureRandom(new byte[] {4, 3, 2, 1}));

        // WHEN
        String secureToken = adapter.generateSecureToken();

        // THEN
        assertThat(secureToken).isNotBlank();
        assertThat(Base64.getUrlDecoder().decode(secureToken)).hasSize(32);
    }

    @Test
    @DisplayName("GIVEN cliente WHEN emitir access token THEN deve assinar JWT sem expor refresh token")
    void shouldIssueSignedJwtAccessToken() {
        // GIVEN
        HmacSha256JwtAccessTokenIssuerAdapter adapter = new HmacSha256JwtAccessTokenIssuerAdapter(
                "change-me-test-jwt-secret-with-at-least-32-characters",
                15
        );
        Instant issuedAt = Instant.parse("2026-05-08T20:00:00Z");

        // WHEN
        IssuedAccessToken issuedAccessToken = adapter.issueAccessToken(UUID.randomUUID(), "CUSTOMER", issuedAt);

        // THEN
        assertThat(issuedAccessToken.accessToken()).contains(".");
        assertThat(issuedAccessToken.accessToken().split("\\.")).hasSize(3);
        assertThat(issuedAccessToken.expiresAt()).isEqualTo(issuedAt.plusSeconds(900));
        assertThat(issuedAccessToken.accessToken()).doesNotContain("refresh");
    }
}
