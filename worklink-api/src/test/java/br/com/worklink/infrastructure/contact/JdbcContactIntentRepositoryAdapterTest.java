package br.com.worklink.infrastructure.contact;

import br.com.worklink.domain.contact.ContactIntent;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class JdbcContactIntentRepositoryAdapterTest {

    @Test
    @DisplayName("Deve persistir intencao de contato usando JdbcTemplate")
    void shouldPersistContactIntentUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcContactIntentRepositoryAdapter adapter = new JdbcContactIntentRepositoryAdapter(jdbcTemplate);
        ContactIntent contactIntent = ContactIntent.registerContactIntent(
                UUID.randomUUID(),
                UUID.randomUUID(),
                "51999999999",
                Instant.parse("2026-05-08T10:15:30Z")
        );

        // WHEN
        ContactIntent savedContactIntent = adapter.saveContactIntent(contactIntent);

        // THEN
        assertThat(savedContactIntent).isEqualTo(contactIntent);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(contactIntent.contactIntentIdentifier()),
                eq(contactIntent.customerIdentifier()),
                eq(contactIntent.professionalIdentifier()),
                eq(contactIntent.professionalWhatsappNumber()),
                eq(contactIntent.createdAt())
        );
    }
}
