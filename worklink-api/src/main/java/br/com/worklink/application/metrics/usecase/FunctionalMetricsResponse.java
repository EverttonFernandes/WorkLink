package br.com.worklink.application.metrics.usecase;

import java.util.List;

public record FunctionalMetricsResponse(
        long searchCount,
        long searchWithoutResultCount,
        long contactCount,
        long postContactFeedbackCount,
        long reviewCount,
        long anonymousReviewCount,
        long professionalReportCount,
        long reviewAnalysisRequestCount,
        boolean rankingAlgorithmEnabled,
        List<ContactMetricResponse> searchesByCategory,
        List<ContactMetricResponse> searchesByCity,
        List<ContactMetricResponse> contactsByProfessional,
        List<ContactMetricResponse> contactsByCategory,
        List<ContactMetricResponse> contactsByCity,
        ProfessionalMetricSummaryResponse professionalSummary,
        ResponsivenessSummaryResponse responsivenessSummary,
        List<ResponsivenessMetricResponse> responsivenessSignals,
        ReputationSummaryResponse reputationSummary,
        List<ReputationMetricResponse> reputationSignals
) {

    public FunctionalMetricsResponse {
        searchesByCategory = searchesByCategory == null ? List.of() : List.copyOf(searchesByCategory);
        searchesByCity = searchesByCity == null ? List.of() : List.copyOf(searchesByCity);
        contactsByProfessional = contactsByProfessional == null ? List.of() : List.copyOf(contactsByProfessional);
        contactsByCategory = contactsByCategory == null ? List.of() : List.copyOf(contactsByCategory);
        contactsByCity = contactsByCity == null ? List.of() : List.copyOf(contactsByCity);
        responsivenessSignals = responsivenessSignals == null ? List.of() : List.copyOf(responsivenessSignals);
        reputationSignals = reputationSignals == null ? List.of() : List.copyOf(reputationSignals);
        professionalSummary = professionalSummary == null
                ? new ProfessionalMetricSummaryResponse(0, 0, 0, 0, 0)
                : professionalSummary;
        responsivenessSummary = responsivenessSummary == null
                ? new ResponsivenessSummaryResponse(0, 0, 0, 0)
                : responsivenessSummary;
        reputationSummary = reputationSummary == null
                ? new ReputationSummaryResponse(reviewCount, 0, anonymousReviewCount, professionalReportCount,
                reviewAnalysisRequestCount)
                : reputationSummary;
    }
}
