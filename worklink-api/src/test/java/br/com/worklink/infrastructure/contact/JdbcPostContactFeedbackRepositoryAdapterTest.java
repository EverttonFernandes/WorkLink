package br.com.worklink.infrastructure.contact;

import br.com.worklink.domain.contact.ContactConversationOutcome;
import br.com.worklink.domain.contact.ContactResponsiveness;
import br.com.worklink.domain.contact.PostContactFeedback;
import br.com.worklink.domain.contact.ServiceExecutionOutcome;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

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

class JdbcPostContactFeedbackRepositoryAdapterTest {

    @Test
    @DisplayName("Deve persistir feedback pos-contato usando JdbcTemplate")
    void shouldPersistPostContactFeedbackUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcPostContactFeedbackRepositoryAdapter adapter = new JdbcPostContactFeedbackRepositoryAdapter(jdbcTemplate);
        PostContactFeedback postContactFeedback = PostContactFeedback.registerPostContactFeedback(
                UUID.randomUUID(),
                UUID.randomUUID(),
                ContactConversationOutcome.CUSTOMER_DID_NOT_REACH_PROFESSIONAL,
                ContactResponsiveness.NO_RESPONSE,
                ServiceExecutionOutcome.SERVICE_NOT_PERFORMED,
                Instant.parse("2026-05-09T12:00:00Z")
        );

        // WHEN
        PostContactFeedback savedPostContactFeedback = adapter.savePostContactFeedback(postContactFeedback);

        // THEN
        assertThat(savedPostContactFeedback).isEqualTo(postContactFeedback);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(postContactFeedback.postContactFeedbackIdentifier()),
                eq(postContactFeedback.contactIntentIdentifier()),
                eq(postContactFeedback.customerIdentifier()),
                eq(postContactFeedback.conversationOutcome().name()),
                eq(postContactFeedback.contactResponsiveness().name()),
                eq(postContactFeedback.serviceExecutionOutcome().name()),
                eq(Timestamp.from(postContactFeedback.createdAt()))
        );
    }

    @Test
    @DisplayName("GIVEN intencao de contato WHEN carregar feedback THEN deve retornar feedback estruturado")
    void shouldLoadPostContactFeedbackByContactIntentIdentifier() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcPostContactFeedbackRepositoryAdapter adapter = new JdbcPostContactFeedbackRepositoryAdapter(jdbcTemplate);
        UUID contactIntentIdentifier = UUID.randomUUID();
        PostContactFeedback feedback = PostContactFeedback.registerPostContactFeedback(
                contactIntentIdentifier,
                UUID.randomUUID(),
                ContactConversationOutcome.CUSTOMER_REACHED_PROFESSIONAL,
                ContactResponsiveness.FAST_RESPONSE,
                ServiceExecutionOutcome.SERVICE_PERFORMED,
                Instant.parse("2026-05-09T12:00:00Z")
        );
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(contactIntentIdentifier)))
                .thenReturn(List.of(feedback));

        // WHEN
        Optional<PostContactFeedback> loadedFeedback = adapter.loadPostContactFeedbackByContactIntentIdentifier(
                contactIntentIdentifier
        );

        // THEN
        assertThat(loadedFeedback).contains(feedback);
    }
}
