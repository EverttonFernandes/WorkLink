package br.com.worklink.domain.contact;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ContactIntentTest {

    @Test
    @DisplayName("Deve registrar intencao de contato com cliente profissional WhatsApp e momento")
    void shouldRegisterContactIntentWithCustomerProfessionalWhatsappAndDate() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        Instant createdAt = Instant.parse("2026-05-08T10:15:30Z");

        // WHEN
        ContactIntent contactIntent = ContactIntent.registerContactIntent(
                customerIdentifier,
                professionalIdentifier,
                " 51 99999-9999 ",
                createdAt
        );

        // THEN
        assertThat(contactIntent.contactIntentIdentifier()).isNotNull();
        assertThat(contactIntent.customerIdentifier()).isEqualTo(customerIdentifier);
        assertThat(contactIntent.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(contactIntent.professionalWhatsappNumber()).isEqualTo("51 99999-9999");
        assertThat(contactIntent.createdAt()).isEqualTo(createdAt);
    }

    @Test
    @DisplayName("Deve rejeitar intencao de contato sem cliente autenticado")
    void shouldRejectContactIntentWithoutAuthenticatedCustomer() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        Instant createdAt = Instant.parse("2026-05-08T10:15:30Z");

        // WHEN / THEN
        assertThatThrownBy(() -> ContactIntent.registerContactIntent(
                null,
                professionalIdentifier,
                "51999999999",
                createdAt
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O cliente autenticado e obrigatorio para registrar contato.");
    }
}
