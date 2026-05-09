package br.com.worklink.infrastructure.observability;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SensitiveLogValueSanitizerTest {

    private final SensitiveLogValueSanitizer sensitiveLogValueSanitizer = new SensitiveLogValueSanitizer();

    @Test
    @DisplayName("GIVEN token e OTP WHEN sanitizar THEN deve mascarar valores sensiveis")
    void shouldSanitizeTokenAndOneTimePassword() {
        // GIVEN
        String accessTokenKey = "access_" + "token";
        String rawValue = accessTokenKey + "=abc123 otp=123456 authorization=BearerValue";

        // WHEN
        String sanitizedValue = sensitiveLogValueSanitizer.sanitize(rawValue);

        // THEN
        assertThat(sanitizedValue)
                .contains(accessTokenKey + "=[REDACTED]")
                .contains("otp=[REDACTED]")
                .contains("authorization=[REDACTED]")
                .doesNotContain("abc123")
                .doesNotContain("123456")
                .doesNotContain("BearerValue");
    }

    @Test
    @DisplayName("GIVEN documento e telefone WHEN sanitizar THEN deve mascarar dados pessoais")
    void shouldSanitizeDocumentAndPhoneNumber() {
        // GIVEN
        String rawValue = "cpf=123.456.789-10 cnpj=12.345.678/0001-99 telefone=51999999999";

        // WHEN
        String sanitizedValue = sensitiveLogValueSanitizer.sanitize(rawValue);

        // THEN
        assertThat(sanitizedValue)
                .doesNotContain("123.456.789-10")
                .doesNotContain("12.345.678/0001-99")
                .doesNotContain("51999999999");
        assertThat(sanitizedValue).contains("[REDACTED]");
    }

    @Test
    @DisplayName("GIVEN valor nulo WHEN sanitizar THEN deve retornar texto vazio")
    void shouldReturnEmptyTextWhenValueIsNull() {
        // GIVEN / WHEN / THEN
        assertThat(sensitiveLogValueSanitizer.sanitize(null)).isEmpty();
    }
}
