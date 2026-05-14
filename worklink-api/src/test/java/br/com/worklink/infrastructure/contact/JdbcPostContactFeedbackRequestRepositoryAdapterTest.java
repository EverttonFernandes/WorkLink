package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.PostContactFeedbackRequestProjection;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcPostContactFeedbackRequestRepositoryAdapterTest {

    @Test
    @DisplayName("GIVEN solicitacoes pendentes WHEN listar THEN deve mapear contato e profissional")
    void shouldListPendingPostContactFeedbackRequests() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcPostContactFeedbackRequestRepositoryAdapter adapter =
                new JdbcPostContactFeedbackRequestRepositoryAdapter(jdbcTemplate);
        UUID customerIdentifier = UUID.randomUUID();
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        Instant createdAt = Instant.parse("2026-05-13T12:00:00Z");
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(customerIdentifier)))
                .thenAnswer(invocation -> {
                    RowMapper<PostContactFeedbackRequestProjection> rowMapper = invocation.getArgument(1);
                    ResultSet resultSet = mock(ResultSet.class);
                    when(resultSet.getObject("contact_intent_identifier", UUID.class)).thenReturn(contactIntentIdentifier);
                    when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professionalIdentifier);
                    when(resultSet.getString("professional_name")).thenReturn("Maria Eletricista");
                    when(resultSet.getTimestamp("created_at")).thenReturn(java.sql.Timestamp.from(createdAt));
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        List<PostContactFeedbackRequestProjection> requests =
                adapter.listPendingPostContactFeedbackRequests(customerIdentifier);

        // THEN
        assertThat(requests).containsExactly(new PostContactFeedbackRequestProjection(
                contactIntentIdentifier,
                professionalIdentifier,
                "Maria Eletricista",
                createdAt
        ));
    }

    @Test
    @DisplayName("GIVEN solicitacao pendente WHEN dispensar THEN deve atualizar somente registros pendentes")
    void shouldDismissPendingPostContactFeedbackRequest() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcPostContactFeedbackRequestRepositoryAdapter adapter =
                new JdbcPostContactFeedbackRequestRepositoryAdapter(jdbcTemplate);
        UUID customerIdentifier = UUID.randomUUID();
        UUID contactIntentIdentifier = UUID.randomUUID();
        when(jdbcTemplate.update(any(String.class), eq(customerIdentifier), eq(contactIntentIdentifier))).thenReturn(1);

        // WHEN
        boolean dismissed = adapter.dismissPostContactFeedbackRequest(customerIdentifier, contactIntentIdentifier);

        // THEN
        assertThat(dismissed).isTrue();
    }

    @Test
    @DisplayName("GIVEN contato iniciado e respondido WHEN persistir request THEN deve usar upsert para status pendente e answered")
    void shouldPersistAndAnswerPostContactFeedbackRequestUsingUpsert() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcPostContactFeedbackRequestRepositoryAdapter adapter =
                new JdbcPostContactFeedbackRequestRepositoryAdapter(jdbcTemplate);
        UUID customerIdentifier = UUID.randomUUID();
        UUID contactIntentIdentifier = UUID.randomUUID();
        Instant createdAt = Instant.parse("2026-05-13T12:00:00Z");

        // WHEN
        adapter.savePendingPostContactFeedbackRequest(customerIdentifier, contactIntentIdentifier, createdAt);
        adapter.markPostContactFeedbackRequestAnswered(customerIdentifier, contactIntentIdentifier);

        // THEN
        verify(jdbcTemplate).update(any(String.class), eq(contactIntentIdentifier), eq(customerIdentifier), eq(createdAt), eq(createdAt));
        verify(jdbcTemplate).update(any(String.class), eq(contactIntentIdentifier), eq(customerIdentifier));
    }
}
