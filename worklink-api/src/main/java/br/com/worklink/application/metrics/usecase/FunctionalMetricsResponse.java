package br.com.worklink.application.metrics.usecase;

import java.util.List;

public record FunctionalMetricsResponse(
        long searchCount,
        long contactCount,
        long postContactFeedbackCount,
        long reviewCount,
        long acceptingNewClientsProfessionalCount,
        long availableTodayProfessionalCount,
        boolean rankingAlgorithmEnabled,
        List<ContactMetricResponse> contactsByProfessional,
        List<ContactMetricResponse> contactsByCategory,
        List<ContactMetricResponse> contactsByCity,
        List<ResponsivenessMetricResponse> responsivenessSignals,
        List<ReputationMetricResponse> reputationSignals
) {

    public FunctionalMetricsResponse {
        contactsByProfessional = contactsByProfessional == null ? List.of() : List.copyOf(contactsByProfessional);
        contactsByCategory = contactsByCategory == null ? List.of() : List.copyOf(contactsByCategory);
        contactsByCity = contactsByCity == null ? List.of() : List.copyOf(contactsByCity);
        responsivenessSignals = responsivenessSignals == null ? List.of() : List.copyOf(responsivenessSignals);
        reputationSignals = reputationSignals == null ? List.of() : List.copyOf(reputationSignals);
    }
}
