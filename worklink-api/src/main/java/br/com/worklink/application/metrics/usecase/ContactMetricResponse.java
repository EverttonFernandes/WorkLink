package br.com.worklink.application.metrics.usecase;

import java.util.UUID;

public record ContactMetricResponse(
        UUID metricIdentifier,
        long contactCount
) {
}
