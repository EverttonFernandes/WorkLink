package br.com.worklink.domain.review;

import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;

import java.time.Instant;
import java.util.UUID;

public record ProfessionalReviewAnalysisRequest(
        UUID reviewAnalysisRequestIdentifier,
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        UUID requestedByProfessionalIdentifier,
        String reason,
        ModerationStatus moderationStatus,
        ModerationDecision moderationDecision,
        String moderationNotes,
        Instant decidedAt,
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
                ModerationStatus.PENDING,
                null,
                null,
                null,
                requireInstant(createdAt)
        );
    }

    public static ProfessionalReviewAnalysisRequest restoreProfessionalReviewAnalysisRequest(
            UUID reviewAnalysisRequestIdentifier,
            UUID professionalReviewIdentifier,
            UUID professionalIdentifier,
            UUID requestedByProfessionalIdentifier,
            String reason,
            ModerationStatus moderationStatus,
            ModerationDecision moderationDecision,
            String moderationNotes,
            Instant decidedAt,
            Instant createdAt
    ) {
        return new ProfessionalReviewAnalysisRequest(
                requireIdentifier(reviewAnalysisRequestIdentifier, "O identificador da solicitacao e obrigatorio."),
                requireIdentifier(professionalReviewIdentifier, "A avaliacao solicitada para analise e obrigatoria."),
                requireIdentifier(professionalIdentifier, "O profissional avaliado e obrigatorio."),
                requireIdentifier(requestedByProfessionalIdentifier, "O profissional solicitante e obrigatorio."),
                normalizeReason(reason),
                requireModerationStatus(moderationStatus),
                moderationDecision,
                normalizeReason(moderationNotes),
                decidedAt,
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

    private static ModerationStatus requireModerationStatus(ModerationStatus moderationStatus) {
        if (moderationStatus == null) {
            throw new BusinessRuleViolationException("O status de moderacao da contestacao e obrigatorio.");
        }
        return moderationStatus;
    }
}
