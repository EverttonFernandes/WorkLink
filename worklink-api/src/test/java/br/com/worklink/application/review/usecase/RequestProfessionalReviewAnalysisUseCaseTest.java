package br.com.worklink.application.review.usecase;

import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.domain.review.ProfessionalReview;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RequestProfessionalReviewAnalysisUseCaseTest {

    private static final UUID PROFESSIONAL_IDENTIFIER = UUID.randomUUID();
    private static final Instant REQUESTED_AT = Instant.parse("2026-05-09T15:00:00Z");

    @Test
    @DisplayName("GIVEN profissional dono da avaliacao WHEN solicitar analise THEN deve registrar pedido")
    void shouldRequestReviewAnalysisForOwnedProfessionalReview() {
        // GIVEN
        ProfessionalReview professionalReview = reviewForProfessional(PROFESSIONAL_IDENTIFIER);
        AtomicReference<ProfessionalReviewAnalysisRequest> savedRequest = new AtomicReference<>();
        RequestProfessionalReviewAnalysisUseCase useCase = useCase(professionalReview, savedRequest);
        AuthenticatedPrincipal professionalPrincipal =
                new AuthenticatedPrincipal(PROFESSIONAL_IDENTIFIER, AuthenticatedProfile.PROFESSIONAL);

        // WHEN
        RequestProfessionalReviewAnalysisResponse response = useCase.requestProfessionalReviewAnalysis(
                new RequestProfessionalReviewAnalysisRequest(
                        professionalPrincipal,
                        professionalReview.professionalReviewIdentifier(),
                        "Conteudo indevido"
                )
        );

        // THEN
        assertThat(savedRequest.get().professionalReviewIdentifier())
                .isEqualTo(professionalReview.professionalReviewIdentifier());
        assertThat(response.requestedByProfessionalIdentifier()).isEqualTo(PROFESSIONAL_IDENTIFIER);
        assertThat(response.reason()).isEqualTo("Conteudo indevido");
    }

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN solicitar analise THEN deve negar")
    void shouldDenyReviewAnalysisForCustomerPrincipal() {
        // GIVEN
        ProfessionalReview professionalReview = reviewForProfessional(PROFESSIONAL_IDENTIFIER);
        RequestProfessionalReviewAnalysisUseCase useCase = useCase(professionalReview, new AtomicReference<>());
        AuthenticatedPrincipal customerPrincipal =
                new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.requestProfessionalReviewAnalysis(
                new RequestProfessionalReviewAnalysisRequest(
                        customerPrincipal,
                        professionalReview.professionalReviewIdentifier(),
                        null
                )
        ))
                .isInstanceOf(AuthorizationDeniedException.class)
                .hasMessage("Apenas profissional autenticado pode solicitar analise da avaliacao.");
    }

    @Test
    @DisplayName("GIVEN outro profissional WHEN solicitar analise THEN deve negar ownership")
    void shouldDenyReviewAnalysisForDifferentProfessional() {
        // GIVEN
        ProfessionalReview professionalReview = reviewForProfessional(PROFESSIONAL_IDENTIFIER);
        RequestProfessionalReviewAnalysisUseCase useCase = useCase(professionalReview, new AtomicReference<>());
        AuthenticatedPrincipal otherProfessional =
                new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.PROFESSIONAL);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.requestProfessionalReviewAnalysis(
                new RequestProfessionalReviewAnalysisRequest(
                        otherProfessional,
                        professionalReview.professionalReviewIdentifier(),
                        null
                )
        ))
                .isInstanceOf(AuthorizationDeniedException.class)
                .hasMessage("Apenas o profissional avaliado pode solicitar analise da avaliacao.");
    }

    private RequestProfessionalReviewAnalysisUseCase useCase(
            ProfessionalReview professionalReview,
            AtomicReference<ProfessionalReviewAnalysisRequest> savedRequest
    ) {
        return new RequestProfessionalReviewAnalysisUseCase(
                professionalReviewIdentifier -> Optional.of(professionalReview),
                analysisRequest -> {
                    savedRequest.set(analysisRequest);
                    return analysisRequest;
                },
                () -> REQUESTED_AT
        );
    }

    private ProfessionalReview reviewForProfessional(UUID professionalIdentifier) {
        return ProfessionalReview.restoreProfessionalReview(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                professionalIdentifier,
                UUID.randomUUID(),
                5,
                "Excelente",
                true,
                null,
                "Usuario anonimo",
                Instant.parse("2026-05-09T13:00:00Z")
        );
    }
}
