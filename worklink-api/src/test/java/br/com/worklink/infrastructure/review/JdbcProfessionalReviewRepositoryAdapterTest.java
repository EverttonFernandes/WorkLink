package br.com.worklink.infrastructure.review;

import br.com.worklink.domain.review.ProfessionalReview;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

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
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.same;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcProfessionalReviewRepositoryAdapterTest {

    @Test
    @DisplayName("GIVEN avaliacao profissional WHEN salvar THEN deve persistir todos os campos rastreaveis")
    void shouldPersistProfessionalReviewWithTraceableFields() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReviewRepositoryAdapter adapter = new JdbcProfessionalReviewRepositoryAdapter(jdbcTemplate);
        ProfessionalReview professionalReview = ProfessionalReview.registerProfessionalReview(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                5,
                "Excelente atendimento",
                true,
                null,
                "Usuario anonimo",
                Instant.parse("2026-05-09T13:00:00Z")
        );

        // WHEN
        ProfessionalReview savedProfessionalReview = adapter.saveProfessionalReview(professionalReview);

        // THEN
        assertThat(savedProfessionalReview).isEqualTo(professionalReview);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(professionalReview.professionalReviewIdentifier()),
                eq(professionalReview.contactIntentIdentifier()),
                eq(professionalReview.postContactFeedbackIdentifier()),
                eq(professionalReview.professionalIdentifier()),
                eq(professionalReview.internalAuthorIdentifier()),
                eq(professionalReview.starRating()),
                eq(professionalReview.comment()),
                eq(professionalReview.anonymousToPublic()),
                eq(professionalReview.publicAuthorIdentifier()),
                eq(professionalReview.publicAuthorDisplayName()),
                eq(professionalReview.hiddenFromPublic()),
                eq(Timestamp.from(professionalReview.createdAt()))
        );
    }

    @Test
    @DisplayName("GIVEN avaliacoes persistidas WHEN listar por profissional THEN deve mapear os campos publicos")
    void shouldListProfessionalReviewsByProfessionalIdentifier() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReviewRepositoryAdapter adapter = new JdbcProfessionalReviewRepositoryAdapter(jdbcTemplate);
        UUID professionalIdentifier = UUID.randomUUID();
        UUID professionalReviewIdentifier = UUID.randomUUID();
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID postContactFeedbackIdentifier = UUID.randomUUID();
        UUID internalAuthorIdentifier = UUID.randomUUID();
        UUID publicAuthorIdentifier = UUID.randomUUID();
        Instant createdAt = Instant.parse("2026-05-09T13:00:00Z");
        ResultSet resultSet = professionalReviewResultSet(
                professionalReviewIdentifier,
                contactIntentIdentifier,
                postContactFeedbackIdentifier,
                professionalIdentifier,
                internalAuthorIdentifier,
                5,
                "Excelente atendimento",
                false,
                publicAuthorIdentifier,
                "Maria Cliente",
                false,
                createdAt
        );
        when(jdbcTemplate.query(
                argThat(sql -> sql.contains("hidden_from_public = FALSE")),
                any(RowMapper.class),
                same(professionalIdentifier)
        )).thenAnswer(invocation -> {
            RowMapper<ProfessionalReview> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<ProfessionalReview> professionalReviews =
                adapter.listProfessionalReviewsByProfessionalIdentifier(professionalIdentifier);

        // THEN
        assertThat(professionalReviews).singleElement().satisfies(professionalReview -> {
            assertThat(professionalReview.professionalReviewIdentifier()).isEqualTo(professionalReviewIdentifier);
            assertThat(professionalReview.contactIntentIdentifier()).isEqualTo(contactIntentIdentifier);
            assertThat(professionalReview.postContactFeedbackIdentifier()).isEqualTo(postContactFeedbackIdentifier);
            assertThat(professionalReview.professionalIdentifier()).isEqualTo(professionalIdentifier);
            assertThat(professionalReview.internalAuthorIdentifier()).isEqualTo(internalAuthorIdentifier);
            assertThat(professionalReview.starRating()).isEqualTo(5);
            assertThat(professionalReview.comment()).isEqualTo("Excelente atendimento");
            assertThat(professionalReview.anonymousToPublic()).isFalse();
            assertThat(professionalReview.publicAuthorIdentifier()).isEqualTo(publicAuthorIdentifier);
            assertThat(professionalReview.publicAuthorDisplayName()).isEqualTo("Maria Cliente");
            assertThat(professionalReview.hiddenFromPublic()).isFalse();
            assertThat(professionalReview.createdAt()).isEqualTo(createdAt);
        });
    }

    @Test
    @DisplayName("GIVEN avaliacao persistida WHEN carregar por identificador THEN deve retornar avaliacao")
    void shouldLoadProfessionalReviewByIdentifier() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReviewRepositoryAdapter adapter = new JdbcProfessionalReviewRepositoryAdapter(jdbcTemplate);
        UUID professionalReviewIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        ResultSet resultSet = professionalReviewResultSet(
                professionalReviewIdentifier,
                UUID.randomUUID(),
                UUID.randomUUID(),
                professionalIdentifier,
                UUID.randomUUID(),
                4,
                null,
                true,
                null,
                "Usuario anonimo",
                false,
                Instant.parse("2026-05-09T13:10:00Z")
        );
        when(jdbcTemplate.query(
                any(String.class),
                any(RowMapper.class),
                same(professionalReviewIdentifier)
        )).thenAnswer(invocation -> {
            RowMapper<ProfessionalReview> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        Optional<ProfessionalReview> professionalReview =
                adapter.loadProfessionalReviewByIdentifier(professionalReviewIdentifier);

        // THEN
        assertThat(professionalReview).isPresent();
        assertThat(professionalReview.orElseThrow().professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(professionalReview.orElseThrow().comment()).isNull();
        assertThat(professionalReview.orElseThrow().anonymousToPublic()).isTrue();
        assertThat(professionalReview.orElseThrow().hiddenFromPublic()).isFalse();
    }

    @Test
    @DisplayName("GIVEN nenhuma avaliacao WHEN carregar por identificador THEN deve retornar vazio")
    void shouldReturnEmptyWhenProfessionalReviewDoesNotExist() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReviewRepositoryAdapter adapter = new JdbcProfessionalReviewRepositoryAdapter(jdbcTemplate);
        UUID professionalReviewIdentifier = UUID.randomUUID();
        doReturn(List.of()).when(jdbcTemplate).query(
                any(String.class),
                any(RowMapper.class),
                same(professionalReviewIdentifier)
        );

        // WHEN
        Optional<ProfessionalReview> professionalReview =
                adapter.loadProfessionalReviewByIdentifier(professionalReviewIdentifier);

        // THEN
        assertThat(professionalReview).isEmpty();
    }

    @Test
    @DisplayName("GIVEN pedido de analise WHEN salvar THEN deve persistir rastreabilidade")
    void shouldPersistProfessionalReviewAnalysisRequest() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReviewRepositoryAdapter adapter = new JdbcProfessionalReviewRepositoryAdapter(jdbcTemplate);
        UUID professionalIdentifier = UUID.randomUUID();
        ProfessionalReviewAnalysisRequest analysisRequest =
                ProfessionalReviewAnalysisRequest.requestProfessionalReviewAnalysis(
                        UUID.randomUUID(),
                        professionalIdentifier,
                        professionalIdentifier,
                        "Comentario indevido",
                        Instant.parse("2026-05-09T14:00:00Z")
                );

        // WHEN
        ProfessionalReviewAnalysisRequest savedAnalysisRequest =
                adapter.saveProfessionalReviewAnalysisRequest(analysisRequest);

        // THEN
        assertThat(savedAnalysisRequest).isEqualTo(analysisRequest);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(analysisRequest.reviewAnalysisRequestIdentifier()),
                eq(analysisRequest.professionalReviewIdentifier()),
                eq(analysisRequest.professionalIdentifier()),
                eq(analysisRequest.requestedByProfessionalIdentifier()),
                eq(analysisRequest.reason()),
                eq(analysisRequest.moderationStatus().name()),
                eq((String) null),
                eq(analysisRequest.moderationNotes()),
                eq((Timestamp) null),
                eq(Timestamp.from(analysisRequest.createdAt()))
        );
    }

    @Test
    @DisplayName("GIVEN moderacao administrativa WHEN atualizar visibilidade THEN deve persistir flag publica")
    void shouldUpdateProfessionalReviewVisibility() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReviewRepositoryAdapter adapter = new JdbcProfessionalReviewRepositoryAdapter(jdbcTemplate);
        UUID professionalReviewIdentifier = UUID.randomUUID();

        // WHEN
        adapter.updateProfessionalReviewVisibility(professionalReviewIdentifier, true);

        // THEN
        verify(jdbcTemplate).update(
                any(String.class),
                eq(true),
                eq(professionalReviewIdentifier)
        );
    }

    private ResultSet professionalReviewResultSet(
            UUID professionalReviewIdentifier,
            UUID contactIntentIdentifier,
            UUID postContactFeedbackIdentifier,
            UUID professionalIdentifier,
            UUID internalAuthorIdentifier,
            int starRating,
            String comment,
            boolean anonymousToPublic,
            UUID publicAuthorIdentifier,
            String publicAuthorDisplayName,
            boolean hiddenFromPublic,
            Instant createdAt
    ) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("professional_review_identifier", UUID.class)).thenReturn(professionalReviewIdentifier);
        when(resultSet.getObject("contact_intent_identifier", UUID.class)).thenReturn(contactIntentIdentifier);
        when(resultSet.getObject("post_contact_feedback_identifier", UUID.class)).thenReturn(postContactFeedbackIdentifier);
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professionalIdentifier);
        when(resultSet.getObject("internal_author_identifier", UUID.class)).thenReturn(internalAuthorIdentifier);
        when(resultSet.getInt("star_rating")).thenReturn(starRating);
        when(resultSet.getString("comment")).thenReturn(comment);
        when(resultSet.getBoolean("anonymous_to_public")).thenReturn(anonymousToPublic);
        when(resultSet.getObject("public_author_identifier", UUID.class)).thenReturn(publicAuthorIdentifier);
        when(resultSet.getString("public_author_display_name")).thenReturn(publicAuthorDisplayName);
        when(resultSet.getBoolean("hidden_from_public")).thenReturn(hiddenFromPublic);
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(createdAt));
        return resultSet;
    }
}
