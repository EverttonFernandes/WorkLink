package br.com.worklink.application.admin.usecase;

import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import java.time.Instant;
import java.util.UUID;

public record AdministrativeReviewAnalysisRequestResponse(
        UUID reviewAnalysisRequestIdentifier,
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        UUID requestedByProfessionalIdentifier,
        String moderationStatus,
        String moderationDecision,
        String moderationNotes,
        Instant decidedAt,
        Instant createdAt
) {

    static AdministrativeReviewAnalysisRequestResponse fromReviewAnalysisRequest(
            ProfessionalReviewAnalysisRequest professionalReviewAnalysisRequest
    ) {
        return new AdministrativeReviewAnalysisRequestResponse(
                professionalReviewAnalysisRequest.reviewAnalysisRequestIdentifier(),
                professionalReviewAnalysisRequest.professionalReviewIdentifier(),
                professionalReviewAnalysisRequest.professionalIdentifier(),
                professionalReviewAnalysisRequest.requestedByProfessionalIdentifier(),
                professionalReviewAnalysisRequest.moderationStatus().name(),
                professionalReviewAnalysisRequest.moderationDecision() == null
                        ? null
                        : professionalReviewAnalysisRequest.moderationDecision().name(),
                professionalReviewAnalysisRequest.moderationNotes(),
                professionalReviewAnalysisRequest.decidedAt(),
                professionalReviewAnalysisRequest.createdAt()
        );
    }
}
