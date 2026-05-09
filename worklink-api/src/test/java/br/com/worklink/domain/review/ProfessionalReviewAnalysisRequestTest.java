package br.com.worklink.domain.review;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class ProfessionalReviewAnalysisRequestTest {

    @Test
    @DisplayName("GIVEN motivo com espacos WHEN solicitar analise THEN deve registrar texto limpo")
    void shouldRegisterReviewAnalysisRequestWithCleanReason() {
        // GIVEN
        UUID professionalReviewIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();

        // WHEN
        ProfessionalReviewAnalysisRequest analysisRequest =
                ProfessionalReviewAnalysisRequest.requestProfessionalReviewAnalysis(
                        professionalReviewIdentifier,
                        professionalIdentifier,
                        professionalIdentifier,
                        "  Comentario indevido  ",
                        Instant.parse("2026-05-09T14:00:00Z")
                );

        // THEN
        assertThat(analysisRequest.professionalReviewIdentifier()).isEqualTo(professionalReviewIdentifier);
        assertThat(analysisRequest.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(analysisRequest.reason()).isEqualTo("Comentario indevido");
    }
}
