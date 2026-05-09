package br.com.worklink.application.review.usecase;

import br.com.worklink.application.review.port.ListProfessionalReviewsByProfessionalIdentifierPort;
import br.com.worklink.domain.review.ProfessionalReview;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

public class ListProfessionalReviewProfileUseCase {

    private final ListProfessionalReviewsByProfessionalIdentifierPort listProfessionalReviewsPort;

    public ListProfessionalReviewProfileUseCase(
            ListProfessionalReviewsByProfessionalIdentifierPort listProfessionalReviewsPort
    ) {
        this.listProfessionalReviewsPort = listProfessionalReviewsPort;
    }

    public ProfessionalReviewProfileResponse listProfessionalReviewProfile(UUID professionalIdentifier) {
        List<ProfessionalReview> reviews = listProfessionalReviewsPort
                .listProfessionalReviewsByProfessionalIdentifier(professionalIdentifier);
        return new ProfessionalReviewProfileResponse(
                professionalIdentifier,
                summaryFromReviews(reviews),
                reviews.stream()
                        .filter(review -> review.comment() != null && !review.comment().isBlank())
                        .sorted(Comparator.comparing(ProfessionalReview::createdAt).reversed())
                        .map(PublicProfessionalReviewResponse::fromProfessionalReview)
                        .toList()
        );
    }

    private ProfessionalReviewSummaryResponse summaryFromReviews(List<ProfessionalReview> reviews) {
        if (reviews.isEmpty()) {
            return new ProfessionalReviewSummaryResponse(0.0, 0, false);
        }
        double averageRating = reviews.stream()
                .mapToInt(ProfessionalReview::starRating)
                .average()
                .orElse(0.0);
        double roundedAverageRating = BigDecimal.valueOf(averageRating)
                .setScale(1, RoundingMode.HALF_UP)
                .doubleValue();
        return new ProfessionalReviewSummaryResponse(roundedAverageRating, reviews.size(), true);
    }
}
