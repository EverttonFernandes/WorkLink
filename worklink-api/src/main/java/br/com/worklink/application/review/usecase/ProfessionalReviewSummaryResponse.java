package br.com.worklink.application.review.usecase;

public record ProfessionalReviewSummaryResponse(
        double averageRating,
        int reviewCount,
        boolean hasReviews
) {
}
