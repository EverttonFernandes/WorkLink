package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.SavePostContactFeedbackPort;
import br.com.worklink.domain.contact.PostContactFeedback;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class JdbcPostContactFeedbackRepositoryAdapter implements SavePostContactFeedbackPort {

    private final JdbcTemplate jdbcTemplate;

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
                postContactFeedback.createdAt()
        );
        return postContactFeedback;
    }
}
