package br.com.worklink.application.review.usecase;

import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import java.time.Instant;
import java.util.UUID;

public record RequestProfessionalReviewAnalysisResponse(
        UUID reviewAnalysisRequestIdentifier,
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        UUID requestedByProfessionalIdentifier,
        String reason,
        Instant createdAt
) {

    static RequestProfessionalReviewAnalysisResponse fromAnalysisRequest(
            ProfessionalReviewAnalysisRequest professionalReviewAnalysisRequest
    ) {
        return new RequestProfessionalReviewAnalysisResponse(
                professionalReviewAnalysisRequest.reviewAnalysisRequestIdentifier(),
                professionalReviewAnalysisRequest.professionalReviewIdentifier(),
                professionalReviewAnalysisRequest.professionalIdentifier(),
                professionalReviewAnalysisRequest.requestedByProfessionalIdentifier(),
                professionalReviewAnalysisRequest.reason(),
                professionalReviewAnalysisRequest.createdAt()
        );
    }
}
