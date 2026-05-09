package br.com.worklink.api.review;

import br.com.worklink.application.review.usecase.ProfessionalReviewProfileResponse;
import br.com.worklink.application.review.usecase.ProfessionalReviewSummaryResponse;
import br.com.worklink.application.review.usecase.PublicProfessionalReviewResponse;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ProfessionalReviewProfileHttpResponse(
        UUID professionalIdentifier,
        ProfessionalReviewSummaryHttpResponse summary,
        List<PublicProfessionalReviewHttpResponse> reviews
) {

    static ProfessionalReviewProfileHttpResponse fromUseCaseResponse(
            ProfessionalReviewProfileResponse response
    ) {
        return new ProfessionalReviewProfileHttpResponse(
                response.professionalIdentifier(),
                ProfessionalReviewSummaryHttpResponse.fromUseCaseResponse(response.summary()),
                response.reviews().stream()
                        .map(PublicProfessionalReviewHttpResponse::fromUseCaseResponse)
                        .toList()
        );
    }

    public record ProfessionalReviewSummaryHttpResponse(
            double averageRating,
            int reviewCount,
            boolean hasReviews
    ) {

        static ProfessionalReviewSummaryHttpResponse fromUseCaseResponse(
                ProfessionalReviewSummaryResponse response
        ) {
            return new ProfessionalReviewSummaryHttpResponse(
                    response.averageRating(),
                    response.reviewCount(),
                    response.hasReviews()
            );
        }
    }

    public record PublicProfessionalReviewHttpResponse(
            UUID professionalReviewIdentifier,
            int starRating,
            String comment,
            boolean anonymousToPublic,
            UUID publicAuthorIdentifier,
            String publicAuthorDisplayName,
            Instant createdAt
    ) {

        static PublicProfessionalReviewHttpResponse fromUseCaseResponse(
                PublicProfessionalReviewResponse response
        ) {
            return new PublicProfessionalReviewHttpResponse(
                    response.professionalReviewIdentifier(),
                    response.starRating(),
                    response.comment(),
                    response.anonymousToPublic(),
                    response.publicAuthorIdentifier(),
                    response.publicAuthorDisplayName(),
                    response.createdAt()
            );
        }
    }
}
