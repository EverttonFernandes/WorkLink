package br.com.worklink.infrastructure.contact;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class WhatsappContactLinkAdapterTest {

    @Test
    @DisplayName("Deve criar link WhatsApp removendo caracteres nao numericos")
    void shouldCreateWhatsappLinkRemovingNonNumericCharacters() {
        // GIVEN
        WhatsappContactLinkAdapter adapter = new WhatsappContactLinkAdapter();

        // WHEN
        String whatsappContactLink = adapter.createWhatsappContactLink("+55 (51) 99999-9999");

        // THEN
        assertThat(whatsappContactLink).isEqualTo("https://wa.me/5551999999999");
    }
}
