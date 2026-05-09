package br.com.worklink.application.metrics.port;

import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;

public interface LoadFunctionalMetricsPort {

    FunctionalMetricsResponse loadFunctionalMetrics();
}
