package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;

import java.util.List;

public record FunctionalMetricsHttpResponse(
        long searchCount,
        long contactCount,
        long postContactFeedbackCount,
        long reviewCount,
        long acceptingNewClientsProfessionalCount,
        long availableTodayProfessionalCount,
        boolean rankingAlgorithmEnabled,
        List<ContactMetricHttpResponse> contactsByProfessional,
        List<ContactMetricHttpResponse> contactsByCategory,
        List<ContactMetricHttpResponse> contactsByCity,
        List<ResponsivenessMetricHttpResponse> responsivenessSignals,
        List<ReputationMetricHttpResponse> reputationSignals
) {

    static FunctionalMetricsHttpResponse fromResponse(FunctionalMetricsResponse response) {
        return new FunctionalMetricsHttpResponse(
                response.searchCount(),
                response.contactCount(),
                response.postContactFeedbackCount(),
                response.reviewCount(),
                response.acceptingNewClientsProfessionalCount(),
                response.availableTodayProfessionalCount(),
                response.rankingAlgorithmEnabled(),
                response.contactsByProfessional().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.contactsByCategory().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.contactsByCity().stream()
                        .map(ContactMetricHttpResponse::fromResponse)
                        .toList(),
                response.responsivenessSignals().stream()
                        .map(ResponsivenessMetricHttpResponse::fromResponse)
                        .toList(),
                response.reputationSignals().stream()
                        .map(ReputationMetricHttpResponse::fromResponse)
                        .toList()
        );
    }
}
