package br.com.worklink.application.metrics.usecase;

public record ProfessionalMetricSummaryResponse(
        long activeProfessionalCount,
        long completeProfessionalCount,
        long availableProfessionalCount,
        long unavailableProfessionalCount,
        long professionalsWithContactCount
) {
}
