package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.SaveContactIntentPort;
import br.com.worklink.application.contact.port.LoadContactIntentByIdentifierPort;
import br.com.worklink.domain.contact.ContactIntent;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcContactIntentRepositoryAdapter implements SaveContactIntentPort, LoadContactIntentByIdentifierPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcContactIntentRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ContactIntent saveContactIntent(ContactIntent contactIntent) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.contact_intentions (
                    contact_intent_identifier,
                    customer_identifier,
                    professional_identifier,
                    professional_whatsapp_number,
                    created_at
                )
                VALUES (?, ?, ?, ?, ?)
                """,
                contactIntent.contactIntentIdentifier(),
                contactIntent.customerIdentifier(),
                contactIntent.professionalIdentifier(),
                contactIntent.professionalWhatsappNumber(),
                Timestamp.from(contactIntent.createdAt())
        );
        return contactIntent;
    }

    @Override
    public Optional<ContactIntent> loadContactIntentByIdentifier(UUID contactIntentIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT contact_intent_identifier,
                       customer_identifier,
                       professional_identifier,
                       professional_whatsapp_number,
                       created_at
                FROM worklink.contact_intentions
                WHERE contact_intent_identifier = ?
                """,
                (resultSet, rowNumber) -> ContactIntent.restoreContactIntent(
                        resultSet.getObject("contact_intent_identifier", UUID.class),
                        resultSet.getObject("customer_identifier", UUID.class),
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getString("professional_whatsapp_number"),
                        resultSet.getTimestamp("created_at").toInstant()
                ),
                contactIntentIdentifier
        ).stream().findFirst();
    }
}
