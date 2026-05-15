package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.SavePostContactFeedbackPort;
import br.com.worklink.application.review.port.LoadPostContactFeedbackByContactIntentIdentifierPort;
import br.com.worklink.domain.contact.ContactConversationOutcome;
import br.com.worklink.domain.contact.ContactResponsiveness;
import br.com.worklink.domain.contact.PostContactFeedback;
import br.com.worklink.domain.contact.ServiceExecutionOutcome;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcPostContactFeedbackRepositoryAdapter implements
        SavePostContactFeedbackPort,
        LoadPostContactFeedbackByContactIntentIdentifierPort {

    private final JdbcTemplate jdbcTemplate;
    private final RowMapper<PostContactFeedback> postContactFeedbackRowMapper = (resultSet, rowNumber) -> new PostContactFeedback(
            resultSet.getObject("post_contact_feedback_identifier", UUID.class),
            resultSet.getObject("contact_intent_identifier", UUID.class),
            resultSet.getObject("customer_identifier", UUID.class),
            ContactConversationOutcome.valueOf(resultSet.getString("conversation_outcome")),
            ContactResponsiveness.valueOf(resultSet.getString("contact_responsiveness")),
            ServiceExecutionOutcome.valueOf(resultSet.getString("service_execution_outcome")),
            resultSet.getTimestamp("created_at").toInstant()
    );

    public JdbcPostContactFeedbackRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public PostContactFeedback savePostContactFeedback(PostContactFeedback postContactFeedback) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.post_contact_feedbacks (
                    post_contact_feedback_identifier,
                    contact_intent_identifier,
                    customer_identifier,
                    conversation_outcome,
                    contact_responsiveness,
                    service_execution_outcome,
                    created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                postContactFeedback.postContactFeedbackIdentifier(),
                postContactFeedback.contactIntentIdentifier(),
                postContactFeedback.customerIdentifier(),
                postContactFeedback.conversationOutcome().name(),
                postContactFeedback.contactResponsiveness().name(),
                postContactFeedback.serviceExecutionOutcome().name(),
                Timestamp.from(postContactFeedback.createdAt())
        );
        return postContactFeedback;
    }

    @Override
    public Optional<PostContactFeedback> loadPostContactFeedbackByContactIntentIdentifier(UUID contactIntentIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT
                    post_contact_feedback_identifier,
                    contact_intent_identifier,
                    customer_identifier,
                    conversation_outcome,
                    contact_responsiveness,
                    service_execution_outcome,
                    created_at
                FROM worklink.post_contact_feedbacks
                WHERE contact_intent_identifier = ?
                """,
                postContactFeedbackRowMapper,
                contactIntentIdentifier
        ).stream().findFirst();
    }
}
