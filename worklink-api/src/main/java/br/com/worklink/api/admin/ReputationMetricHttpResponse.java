package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.ReputationMetricResponse;

import java.util.UUID;

public record ReputationMetricHttpResponse(
        UUID professionalIdentifier,
        double averageRating,
        long reviewCount
) {

    static ReputationMetricHttpResponse fromResponse(ReputationMetricResponse response) {
        return new ReputationMetricHttpResponse(
                response.professionalIdentifier(),
                response.averageRating(),
                response.reviewCount()
        );
    }
}
