package br.com.worklink.application.review.usecase;

import java.util.List;
import java.util.UUID;

public record ProfessionalReviewProfileResponse(
        UUID professionalIdentifier,
        ProfessionalReviewSummaryResponse summary,
        List<PublicProfessionalReviewResponse> reviews
) {
}
