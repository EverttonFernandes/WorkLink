package br.com.worklink.infrastructure.contact;

import br.com.worklink.domain.contact.ContactIntent;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
                eq(Timestamp.from(contactIntent.createdAt()))
        );
    }

    @Test
    @DisplayName("Deve carregar intencao de contato por identificador usando JdbcTemplate")
    void shouldLoadContactIntentByIdentifierUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcContactIntentRepositoryAdapter adapter = new JdbcContactIntentRepositoryAdapter(jdbcTemplate);
        ContactIntent contactIntent = validContactIntent();
        ResultSet resultSet = contactIntentResultSet(contactIntent);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(contactIntent.contactIntentIdentifier())))
                .thenAnswer(invocation -> {
                    RowMapper<ContactIntent> rowMapper = invocation.getArgument(1);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        Optional<ContactIntent> loadedContactIntent = adapter.loadContactIntentByIdentifier(contactIntent.contactIntentIdentifier());

        // THEN
        assertThat(loadedContactIntent).contains(contactIntent);
    }

    private ContactIntent validContactIntent() {
        return ContactIntent.registerContactIntent(
                UUID.randomUUID(),
                UUID.randomUUID(),
                "51999999999",
                Instant.parse("2026-05-08T10:15:30Z")
        );
    }

    private ResultSet contactIntentResultSet(ContactIntent contactIntent) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("contact_intent_identifier", UUID.class)).thenReturn(contactIntent.contactIntentIdentifier());
        when(resultSet.getObject("customer_identifier", UUID.class)).thenReturn(contactIntent.customerIdentifier());
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(contactIntent.professionalIdentifier());
        when(resultSet.getString("professional_whatsapp_number")).thenReturn(contactIntent.professionalWhatsappNumber());
        when(resultSet.getTimestamp("created_at")).thenReturn(java.sql.Timestamp.from(contactIntent.createdAt()));
        return resultSet;
    }
}
