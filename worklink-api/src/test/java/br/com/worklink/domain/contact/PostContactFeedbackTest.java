package br.com.worklink.domain.contact;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PostContactFeedbackTest {

    @Test
    @DisplayName("Deve registrar feedback pos-contato com respostas estruturadas")
    void shouldRegisterPostContactFeedbackWithStructuredAnswers() {
        // GIVEN
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID customerIdentifier = UUID.randomUUID();
        Instant createdAt = Instant.parse("2026-05-09T12:00:00Z");

        // WHEN
        PostContactFeedback postContactFeedback = PostContactFeedback.registerPostContactFeedback(
                contactIntentIdentifier,
                customerIdentifier,
                ContactConversationOutcome.CUSTOMER_REACHED_PROFESSIONAL,
                ContactResponsiveness.FAST_RESPONSE,
                ServiceExecutionOutcome.SERVICE_PERFORMED,
                createdAt
        );

        // THEN
        assertThat(postContactFeedback.postContactFeedbackIdentifier()).isNotNull();
        assertThat(postContactFeedback.contactIntentIdentifier()).isEqualTo(contactIntentIdentifier);
        assertThat(postContactFeedback.customerIdentifier()).isEqualTo(customerIdentifier);
        assertThat(postContactFeedback.createdAt()).isEqualTo(createdAt);
    }

    @Test
    @DisplayName("Deve rejeitar feedback sem responsividade percebida")
    void shouldRejectFeedbackWithoutPerceivedResponsiveness() {
        // GIVEN
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID customerIdentifier = UUID.randomUUID();

        // WHEN / THEN
        assertThatThrownBy(() -> PostContactFeedback.registerPostContactFeedback(
                contactIntentIdentifier,
                customerIdentifier,
                ContactConversationOutcome.CUSTOMER_REACHED_PROFESSIONAL,
                null,
                ServiceExecutionOutcome.SERVICE_PERFORMED,
                Instant.parse("2026-05-09T12:00:00Z")
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("Informe a responsividade percebida.");
    }
}
