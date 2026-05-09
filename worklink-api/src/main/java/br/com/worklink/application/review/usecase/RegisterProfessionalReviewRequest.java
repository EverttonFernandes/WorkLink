package br.com.worklink.application.review.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.UUID;

public record RegisterProfessionalReviewRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        UUID contactIntentIdentifier,
        int starRating,
        String comment,
        boolean anonymousToPublic
) {
}
