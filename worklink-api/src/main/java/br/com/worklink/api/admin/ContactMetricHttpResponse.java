package br.com.worklink.api.admin;

import br.com.worklink.application.metrics.usecase.ContactMetricResponse;

import java.util.UUID;

public record ContactMetricHttpResponse(
        UUID metricIdentifier,
        long contactCount
) {

    static ContactMetricHttpResponse fromResponse(ContactMetricResponse response) {
        return new ContactMetricHttpResponse(response.metricIdentifier(), response.contactCount());
    }
}
