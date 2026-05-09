package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.SaveContactIntentPort;
import br.com.worklink.domain.contact.ContactIntent;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class JdbcContactIntentRepositoryAdapter implements SaveContactIntentPort {

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
                contactIntent.createdAt()
        );
        return contactIntent;
    }
}
