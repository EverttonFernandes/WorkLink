package br.com.worklink.application.review.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.UUID;

public record RequestProfessionalReviewAnalysisRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        UUID professionalReviewIdentifier,
        String reason
) {
}
