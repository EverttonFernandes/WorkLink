package br.com.worklink.application.review.usecase;

import java.time.Instant;
import java.util.UUID;

public record RegisterProfessionalReviewResponse(
        UUID professionalReviewIdentifier,
        UUID contactIntentIdentifier,
        UUID professionalIdentifier,
        int starRating,
        String comment,
        boolean anonymousToPublic,
        UUID publicAuthorIdentifier,
        String publicAuthorDisplayName,
        Instant createdAt
) {
}
