package br.com.worklink.domain.review;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record ProfessionalReviewAnalysisRequest(
        UUID reviewAnalysisRequestIdentifier,
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        UUID requestedByProfessionalIdentifier,
        String reason,
        Instant createdAt
) {

    public static ProfessionalReviewAnalysisRequest requestProfessionalReviewAnalysis(
            UUID professionalReviewIdentifier,
            UUID professionalIdentifier,
            UUID requestedByProfessionalIdentifier,
            String reason,
            Instant createdAt
    ) {
        return new ProfessionalReviewAnalysisRequest(
                UUID.randomUUID(),
                requireIdentifier(professionalReviewIdentifier, "A avaliacao solicitada para analise e obrigatoria."),
                requireIdentifier(professionalIdentifier, "O profissional avaliado e obrigatorio."),
                requireIdentifier(requestedByProfessionalIdentifier, "O profissional solicitante e obrigatorio."),
                normalizeReason(reason),
                requireInstant(createdAt)
        );
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static String normalizeReason(String reason) {
        if (reason == null || reason.isBlank()) {
            return null;
        }
        return reason.trim();
    }

    private static Instant requireInstant(Instant instant) {
        if (instant == null) {
            throw new BusinessRuleViolationException("O momento da solicitacao de analise e obrigatorio.");
        }
        return instant;
    }
}
