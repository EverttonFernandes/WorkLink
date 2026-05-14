package br.com.worklink.application.metrics.usecase;

public record ReputationSummaryResponse(
        long reviewCount,
        double averageRating,
        long anonymousReviewCount,
        long professionalReportCount,
        long reviewAnalysisRequestCount
) {
}
