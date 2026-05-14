package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.ProfessionalMetricSummaryResponse;

public record ProfessionalMetricSummaryHttpResponse(
        long activeProfessionalCount,
        long completeProfessionalCount,
        long availableProfessionalCount,
        long unavailableProfessionalCount,
        long professionalsWithContactCount
) {

    static ProfessionalMetricSummaryHttpResponse fromResponse(ProfessionalMetricSummaryResponse response) {
        return new ProfessionalMetricSummaryHttpResponse(
                response.activeProfessionalCount(),
                response.completeProfessionalCount(),
                response.availableProfessionalCount(),
                response.unavailableProfessionalCount(),
                response.professionalsWithContactCount()
        );
    }
}
