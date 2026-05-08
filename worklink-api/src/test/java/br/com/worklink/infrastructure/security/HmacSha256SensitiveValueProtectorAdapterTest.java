package br.com.worklink.infrastructure.security;

import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class HmacSha256SensitiveValueProtectorAdapterTest {

    @Test
    @DisplayName("Deve proteger valor sensivel com hash deterministico sem expor valor original")
    void shouldProtectSensitiveValueWithDeterministicHashWithoutExposingOriginalValue() {
        // GIVEN
        HmacSha256SensitiveValueProtectorAdapter protector =
                new HmacSha256SensitiveValueProtectorAdapter("pepper-seguro-de-teste");

        // WHEN
        String firstProtectedValue = protector.protectSensitiveValue(
                "123.456.789-00",
                ProtectedSensitiveValuePurpose.DOCUMENT_NUMBER
        );
        String secondProtectedValue = protector.protectSensitiveValue(
                "123.456.789-00",
                ProtectedSensitiveValuePurpose.DOCUMENT_NUMBER
        );

        // THEN
        assertThat(firstProtectedValue).isEqualTo(secondProtectedValue);
        assertThat(firstProtectedValue).hasSize(64);
        assertThat(firstProtectedValue).doesNotContain("123");
        assertThat(firstProtectedValue).doesNotContain("789");
    }

    @Test
    @DisplayName("Deve gerar hashes diferentes para finalidades diferentes")
    void shouldGenerateDifferentHashesForDifferentPurposes() {
        // GIVEN
        HmacSha256SensitiveValueProtectorAdapter protector =
                new HmacSha256SensitiveValueProtectorAdapter("pepper-seguro-de-teste");

        // WHEN
        String protectedOtp = protector.protectSensitiveValue(
                "123456",
                ProtectedSensitiveValuePurpose.ONE_TIME_PASSWORD
        );
        String protectedRefreshToken = protector.protectSensitiveValue(
                "123456",
                ProtectedSensitiveValuePurpose.REFRESH_TOKEN
        );

        // THEN
        assertThat(protectedOtp).isNotEqualTo(protectedRefreshToken);
    }

    @Test
    @DisplayName("Deve exigir pepper configurado")
    void shouldRequireConfiguredPepper() {
        // GIVEN
        String missingPepper = " ";

        // WHEN / THEN
        assertThatThrownBy(() -> new HmacSha256SensitiveValueProtectorAdapter(missingPepper))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("O pepper de valores sensiveis e obrigatorio.");
    }
}
