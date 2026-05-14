package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;

import java.util.List;

public record FunctionalMetricsHttpResponse(
        long searchCount,
        long searchWithoutResultCount,
        long contactCount,
        long postContactFeedbackCount,
        long reviewCount,
        long anonymousReviewCount,
        long professionalReportCount,
        long reviewAnalysisRequestCount,
        boolean rankingAlgorithmEnabled,
        List<ContactMetricHttpResponse> searchesByCategory,
        List<ContactMetricHttpResponse> searchesByCity,
        List<ContactMetricHttpResponse> contactsByProfessional,
        List<ContactMetricHttpResponse> contactsByCategory,
        List<ContactMetricHttpResponse> contactsByCity,
        ProfessionalMetricSummaryHttpResponse professionalSummary,
        ResponsivenessSummaryHttpResponse responsivenessSummary,
        List<ResponsivenessMetricHttpResponse> responsivenessSignals,
        ReputationSummaryHttpResponse reputationSummary,
        List<ReputationMetricHttpResponse> reputationSignals
) {

    static FunctionalMetricsHttpResponse fromResponse(FunctionalMetricsResponse response) {
        return new FunctionalMetricsHttpResponse(
                response.searchCount(),
                response.searchWithoutResultCount(),
                response.contactCount(),
                response.postContactFeedbackCount(),
                response.reviewCount(),
                response.anonymousReviewCount(),
                response.professionalReportCount(),
                response.reviewAnalysisRequestCount(),
                response.rankingAlgorithmEnabled(),
                response.searchesByCategory().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.searchesByCity().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.contactsByProfessional().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.contactsByCategory().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.contactsByCity().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                ProfessionalMetricSummaryHttpResponse.fromResponse(response.professionalSummary()),
                ResponsivenessSummaryHttpResponse.fromResponse(response.responsivenessSummary()),
                response.responsivenessSignals().stream()
                        .map(ResponsivenessMetricHttpResponse::fromResponse)
                        .toList(),
                ReputationSummaryHttpResponse.fromResponse(response.reputationSummary()),
                response.reputationSignals().stream()
                        .map(ReputationMetricHttpResponse::fromResponse)
                        .toList()
        );
    }
}
