package br.com.worklink.api.review;

import br.com.worklink.application.review.usecase.RegisterProfessionalReviewResponse;

import java.time.Instant;
import java.util.UUID;

public record RegisterProfessionalReviewHttpResponse(
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

    static RegisterProfessionalReviewHttpResponse fromUseCaseResponse(
            RegisterProfessionalReviewResponse response
    ) {
        return new RegisterProfessionalReviewHttpResponse(
                response.professionalReviewIdentifier(),
                response.contactIntentIdentifier(),
                response.professionalIdentifier(),
                response.starRating(),
                response.comment(),
                response.anonymousToPublic(),
                response.publicAuthorIdentifier(),
                response.publicAuthorDisplayName(),
                response.createdAt()
        );
    }
}
