package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.ResponsivenessMetricResponse;

public record ResponsivenessMetricHttpResponse(
        String contactResponsiveness,
        long feedbackCount
) {

    static ResponsivenessMetricHttpResponse fromResponse(ResponsivenessMetricResponse response) {
        return new ResponsivenessMetricHttpResponse(response.contactResponsiveness(), response.feedbackCount());
    }
}
