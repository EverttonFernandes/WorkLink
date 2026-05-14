package br.com.worklink.domain.review;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record ProfessionalReview(
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
) {

    private static final int MINIMUM_STAR_RATING = 1;
    private static final int MAXIMUM_STAR_RATING = 5;

    public static ProfessionalReview registerProfessionalReview(
            UUID contactIntentIdentifier,
            UUID postContactFeedbackIdentifier,
            UUID professionalIdentifier,
            UUID internalAuthorIdentifier,
            int starRating,
            String comment,
            boolean anonymousToPublic,
            UUID publicAuthorIdentifier,
            String publicAuthorDisplayName,
            Instant createdAt
    ) {
        return new ProfessionalReview(
                UUID.randomUUID(),
                requireIdentifier(contactIntentIdentifier, "A intencao de contato da avaliacao e obrigatoria."),
                requireIdentifier(postContactFeedbackIdentifier, "O feedback pos-contato da avaliacao e obrigatorio."),
                requireIdentifier(professionalIdentifier, "O profissional avaliado e obrigatorio."),
                requireIdentifier(internalAuthorIdentifier, "A autoria interna da avaliacao e obrigatoria."),
                requireStarRating(starRating),
                normalizeComment(comment),
                anonymousToPublic,
                publicAuthorIdentifier,
                requirePublicAuthorDisplayName(publicAuthorDisplayName),
                false,
                requireInstant(createdAt)
        );
    }

    public static ProfessionalReview restoreProfessionalReview(
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
    ) {
        return new ProfessionalReview(
                requireIdentifier(professionalReviewIdentifier, "A avaliacao profissional e obrigatoria."),
                requireIdentifier(contactIntentIdentifier, "A intencao de contato da avaliacao e obrigatoria."),
                requireIdentifier(postContactFeedbackIdentifier, "O feedback pos-contato da avaliacao e obrigatorio."),
                requireIdentifier(professionalIdentifier, "O profissional avaliado e obrigatorio."),
                requireIdentifier(internalAuthorIdentifier, "A autoria interna da avaliacao e obrigatoria."),
                requireStarRating(starRating),
                normalizeComment(comment),
                anonymousToPublic,
                publicAuthorIdentifier,
                requirePublicAuthorDisplayName(publicAuthorDisplayName),
                hiddenFromPublic,
                requireInstant(createdAt)
        );
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static int requireStarRating(int starRating) {
        if (starRating < MINIMUM_STAR_RATING || starRating > MAXIMUM_STAR_RATING) {
            throw new BusinessRuleViolationException("A nota da avaliacao deve estar entre 1 e 5 estrelas.");
        }
        return starRating;
    }

    private static String normalizeComment(String comment) {
        if (comment == null || comment.isBlank()) {
            return null;
        }
        return comment.trim();
    }

    private static String requirePublicAuthorDisplayName(String publicAuthorDisplayName) {
        if (publicAuthorDisplayName == null || publicAuthorDisplayName.isBlank()) {
            throw new BusinessRuleViolationException("O nome publico da avaliacao e obrigatorio.");
        }
        return publicAuthorDisplayName.trim();
    }

    private static Instant requireInstant(Instant instant) {
        if (instant == null) {
            throw new BusinessRuleViolationException("O momento da avaliacao e obrigatorio.");
        }
        return instant;
    }
}
