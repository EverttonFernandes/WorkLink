package br.com.worklink.api.admin;

import br.com.worklink.application.admin.usecase.AdministrativeReviewAnalysisRequestResponse;

import java.time.Instant;
import java.util.UUID;

public record AdministrativeReviewAnalysisRequestHttpResponse(
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

    static AdministrativeReviewAnalysisRequestHttpResponse fromResponse(
            AdministrativeReviewAnalysisRequestResponse administrativeReviewAnalysisRequestResponse
    ) {
        return new AdministrativeReviewAnalysisRequestHttpResponse(
                administrativeReviewAnalysisRequestResponse.reviewAnalysisRequestIdentifier(),
                administrativeReviewAnalysisRequestResponse.professionalReviewIdentifier(),
                administrativeReviewAnalysisRequestResponse.professionalIdentifier(),
                administrativeReviewAnalysisRequestResponse.requestedByProfessionalIdentifier(),
                administrativeReviewAnalysisRequestResponse.moderationStatus(),
                administrativeReviewAnalysisRequestResponse.moderationDecision(),
                administrativeReviewAnalysisRequestResponse.moderationNotes(),
                administrativeReviewAnalysisRequestResponse.decidedAt(),
                administrativeReviewAnalysisRequestResponse.createdAt()
        );
    }
}
