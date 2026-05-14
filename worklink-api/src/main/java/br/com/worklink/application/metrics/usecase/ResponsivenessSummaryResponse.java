package br.com.worklink.application.metrics.usecase;

public record ResponsivenessSummaryResponse(
        double respondedContactPercentage,
        double noResponsePercentage,
        double servicePerformedPercentage,
        double postContactAnswerRatePercentage
) {
}
