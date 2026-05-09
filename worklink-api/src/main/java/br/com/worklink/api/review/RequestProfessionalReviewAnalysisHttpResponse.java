package br.com.worklink.api.review;

import br.com.worklink.application.review.usecase.RequestProfessionalReviewAnalysisResponse;

import java.time.Instant;
import java.util.UUID;

public record RequestProfessionalReviewAnalysisHttpResponse(
        UUID reviewAnalysisRequestIdentifier,
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        UUID requestedByProfessionalIdentifier,
        String reason,
        Instant createdAt
) {

    static RequestProfessionalReviewAnalysisHttpResponse fromUseCaseResponse(
            RequestProfessionalReviewAnalysisResponse response
    ) {
        return new RequestProfessionalReviewAnalysisHttpResponse(
                response.reviewAnalysisRequestIdentifier(),
                response.professionalReviewIdentifier(),
                response.professionalIdentifier(),
                response.requestedByProfessionalIdentifier(),
                response.reason(),
                response.createdAt()
        );
    }
}
