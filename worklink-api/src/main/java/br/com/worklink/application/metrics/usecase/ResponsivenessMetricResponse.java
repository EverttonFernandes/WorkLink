package br.com.worklink.application.metrics.usecase;

public record ResponsivenessMetricResponse(
        String contactResponsiveness,
        long feedbackCount
) {
}
