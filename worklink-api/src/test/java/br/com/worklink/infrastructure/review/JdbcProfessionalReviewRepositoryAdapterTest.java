package br.com.worklink.infrastructure.review;

import br.com.worklink.domain.review.ProfessionalReview;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

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
                eq(professionalReview.createdAt())
        );
    }
}
