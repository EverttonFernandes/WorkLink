package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.DismissPostContactFeedbackRequestPort;
import br.com.worklink.application.contact.port.ListPendingPostContactFeedbackRequestsPort;
import br.com.worklink.application.contact.port.MarkPostContactFeedbackRequestAnsweredPort;
import br.com.worklink.application.contact.port.PostContactFeedbackRequestProjection;
import br.com.worklink.application.contact.port.SavePostContactFeedbackRequestPort;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public class JdbcPostContactFeedbackRequestRepositoryAdapter implements
        SavePostContactFeedbackRequestPort,
        ListPendingPostContactFeedbackRequestsPort,
        MarkPostContactFeedbackRequestAnsweredPort,
        DismissPostContactFeedbackRequestPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcPostContactFeedbackRequestRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void savePendingPostContactFeedbackRequest(
            UUID customerIdentifier,
            UUID contactIntentIdentifier,
            java.time.Instant createdAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.post_contact_feedback_requests (
                    contact_intent_identifier,
                    customer_identifier,
                    request_status,
                    created_at,
                    updated_at
                )
                VALUES (?, ?, 'PENDING', ?, ?)
                ON CONFLICT (contact_intent_identifier) DO UPDATE
                SET customer_identifier = EXCLUDED.customer_identifier,
                    request_status = 'PENDING',
                    updated_at = EXCLUDED.updated_at
                """,
                contactIntentIdentifier,
                customerIdentifier,
                createdAt,
                createdAt
        );
    }

    @Override
    public List<PostContactFeedbackRequestProjection> listPendingPostContactFeedbackRequests(UUID customerIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT requests.contact_intent_identifier,
                       contacts.professional_identifier,
                       professionals.professional_name,
                       contacts.created_at
                FROM worklink.post_contact_feedback_requests requests
                JOIN worklink.contact_intentions contacts
                  ON contacts.contact_intent_identifier = requests.contact_intent_identifier
                JOIN worklink.professionals professionals
                  ON professionals.professional_identifier = contacts.professional_identifier
                WHERE requests.customer_identifier = ?
                  AND requests.request_status = 'PENDING'
                ORDER BY contacts.created_at DESC
                """,
                (resultSet, rowNumber) -> new PostContactFeedbackRequestProjection(
                        resultSet.getObject("contact_intent_identifier", UUID.class),
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getString("professional_name"),
                        resultSet.getTimestamp("created_at").toInstant()
                ),
                customerIdentifier
        );
    }

    @Override
    public void markPostContactFeedbackRequestAnswered(UUID customerIdentifier, UUID contactIntentIdentifier) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.post_contact_feedback_requests (
                    contact_intent_identifier,
                    customer_identifier,
                    request_status,
                    created_at,
                    updated_at
                )
                VALUES (?, ?, 'ANSWERED', NOW(), NOW())
                ON CONFLICT (contact_intent_identifier) DO UPDATE
                SET customer_identifier = EXCLUDED.customer_identifier,
                    request_status = 'ANSWERED',
                    updated_at = NOW()
                """,
                contactIntentIdentifier,
                customerIdentifier
        );
    }

    @Override
    public boolean dismissPostContactFeedbackRequest(UUID customerIdentifier, UUID contactIntentIdentifier) {
        int updatedRows = jdbcTemplate.update(
                """
                UPDATE worklink.post_contact_feedback_requests
                SET request_status = 'DISMISSED',
                    updated_at = NOW()
                WHERE customer_identifier = ?
                  AND contact_intent_identifier = ?
                  AND request_status = 'PENDING'
                """,
                customerIdentifier,
                contactIntentIdentifier
        );
        return updatedRows > 0;
    }
}
