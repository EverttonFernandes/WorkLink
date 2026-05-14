package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.ResponsivenessSummaryResponse;

public record ResponsivenessSummaryHttpResponse(
        double respondedContactPercentage,
        double noResponsePercentage,
        double servicePerformedPercentage,
        double postContactAnswerRatePercentage
) {

    static ResponsivenessSummaryHttpResponse fromResponse(ResponsivenessSummaryResponse response) {
        return new ResponsivenessSummaryHttpResponse(
                response.respondedContactPercentage(),
                response.noResponsePercentage(),
                response.servicePerformedPercentage(),
                response.postContactAnswerRatePercentage()
        );
    }
}
