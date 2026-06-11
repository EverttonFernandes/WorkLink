package br.com.worklink.domain.review;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalReviewTest {

    @Test
    @DisplayName("GIVEN avaliacao valida WHEN registrar THEN deve preservar autoria interna e comentario limpo")
    void shouldRegisterValidProfessionalReviewWithInternalAuthorshipAndCleanComment() {
        // GIVEN
        UUID internalAuthorIdentifier = UUID.randomUUID();

        // WHEN
        ProfessionalReview professionalReview = ProfessionalReview.registerProfessionalReview(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                internalAuthorIdentifier,
                5,
                "  Excelente atendimento  ",
                true,
                null,
                "Usuario anonimo",
                Instant.parse("2026-05-09T13:00:00Z")
        );

        // THEN
        assertThat(professionalReview.internalAuthorIdentifier()).isEqualTo(internalAuthorIdentifier);
        assertThat(professionalReview.comment()).isEqualTo("Excelente atendimento");
        assertThat(professionalReview.anonymousToPublic()).isTrue();
        assertThat(professionalReview.publicAuthorIdentifier()).isNull();
        assertThat(professionalReview.publicAuthorDisplayName()).isEqualTo("Usuario anonimo");
        assertThat(professionalReview.hiddenFromPublic()).isFalse();
    }

    @Test
    @DisplayName("GIVEN nota fora da escala WHEN registrar THEN deve rejeitar avaliacao")
    void shouldRejectProfessionalReviewWithInvalidStarRating() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> ProfessionalReview.registerProfessionalReview(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                0,
                null,
                false,
                UUID.randomUUID(),
                "Cliente Exemplo",
                Instant.parse("2026-05-09T13:00:00Z")
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A nota da avaliacao deve estar entre 1 e 5 estrelas.");
    }
}
