package br.com.worklink.application.metrics.usecase;

import java.util.UUID;

public record ReputationMetricResponse(
        UUID professionalIdentifier,
        double averageRating,
        long reviewCount
) {
}
