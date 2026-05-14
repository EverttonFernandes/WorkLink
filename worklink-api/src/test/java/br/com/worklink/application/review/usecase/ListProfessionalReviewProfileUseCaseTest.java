package br.com.worklink.application.review.usecase;

import br.com.worklink.domain.review.ProfessionalReview;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class ListProfessionalReviewProfileUseCaseTest {

    private static final UUID PROFESSIONAL_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("GIVEN avaliacoes existentes WHEN listar perfil THEN deve calcular media e comentarios publicos")
    void shouldListReviewProfileWithAverageAndPublicComments() {
        // GIVEN
        ProfessionalReview firstReview = review(5, "Excelente", true, "Usuario anonimo", Instant.parse("2026-05-09T14:00:00Z"));
        ProfessionalReview secondReview = review(4, null, false, "Cliente WorkLink", Instant.parse("2026-05-09T13:00:00Z"));
        ListProfessionalReviewProfileUseCase useCase = new ListProfessionalReviewProfileUseCase(
                professionalIdentifier -> List.of(firstReview, secondReview)
        );

        // WHEN
        ProfessionalReviewProfileResponse response = useCase.listProfessionalReviewProfile(PROFESSIONAL_IDENTIFIER);

        // THEN
        assertThat(response.summary().hasReviews()).isTrue();
        assertThat(response.summary().reviewCount()).isEqualTo(2);
        assertThat(response.summary().averageRating()).isEqualTo(4.5);
        assertThat(response.reviews()).hasSize(1);
        assertThat(response.reviews().getFirst().publicAuthorDisplayName()).isEqualTo("Usuario anonimo");
        assertThat(response.reviews().getFirst().publicAuthorIdentifier()).isNull();
    }

    @Test
    @DisplayName("GIVEN profissional sem avaliacoes WHEN listar perfil THEN deve retornar estado vazio")
    void shouldListEmptyReviewProfile() {
        // GIVEN
        ListProfessionalReviewProfileUseCase useCase = new ListProfessionalReviewProfileUseCase(
                professionalIdentifier -> List.of()
        );

        // WHEN
        ProfessionalReviewProfileResponse response = useCase.listProfessionalReviewProfile(PROFESSIONAL_IDENTIFIER);

        // THEN
        assertThat(response.summary().hasReviews()).isFalse();
        assertThat(response.summary().reviewCount()).isZero();
        assertThat(response.summary().averageRating()).isZero();
        assertThat(response.reviews()).isEmpty();
    }

    private ProfessionalReview review(
            int starRating,
            String comment,
            boolean anonymousToPublic,
            String publicAuthorDisplayName,
            Instant createdAt
    ) {
        UUID internalAuthorIdentifier = UUID.randomUUID();
        return ProfessionalReview.restoreProfessionalReview(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                PROFESSIONAL_IDENTIFIER,
                internalAuthorIdentifier,
                starRating,
                comment,
                anonymousToPublic,
                anonymousToPublic ? null : internalAuthorIdentifier,
                publicAuthorDisplayName,
                false,
                createdAt
        );
    }
}
