package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.ReputationSummaryResponse;

public record ReputationSummaryHttpResponse(
        long reviewCount,
        double averageRating,
        long anonymousReviewCount,
        long professionalReportCount,
        long reviewAnalysisRequestCount
) {

    static ReputationSummaryHttpResponse fromResponse(ReputationSummaryResponse response) {
        return new ReputationSummaryHttpResponse(
                response.reviewCount(),
                response.averageRating(),
                response.anonymousReviewCount(),
                response.professionalReportCount(),
                response.reviewAnalysisRequestCount()
        );
    }
}
