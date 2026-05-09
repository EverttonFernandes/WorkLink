package br.com.worklink.api.review;

import java.util.UUID;

public record RegisterProfessionalReviewHttpRequest(
        UUID contactIntentIdentifier,
        int starRating,
        String comment,
        boolean anonymousToPublic
) {
}
