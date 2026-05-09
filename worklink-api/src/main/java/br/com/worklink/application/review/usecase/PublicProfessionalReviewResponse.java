package br.com.worklink.application.review.usecase;

import br.com.worklink.domain.review.ProfessionalReview;

import java.time.Instant;
import java.util.UUID;

public record PublicProfessionalReviewResponse(
        UUID professionalReviewIdentifier,
        int starRating,
        String comment,
        boolean anonymousToPublic,
        UUID publicAuthorIdentifier,
        String publicAuthorDisplayName,
        Instant createdAt
) {

    static PublicProfessionalReviewResponse fromProfessionalReview(ProfessionalReview professionalReview) {
        return new PublicProfessionalReviewResponse(
                professionalReview.professionalReviewIdentifier(),
                professionalReview.starRating(),
                professionalReview.comment(),
                professionalReview.anonymousToPublic(),
                professionalReview.publicAuthorIdentifier(),
                professionalReview.publicAuthorDisplayName(),
                professionalReview.createdAt()
        );
    }
}
