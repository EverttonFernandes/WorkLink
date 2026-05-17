package br.com.worklink.application.metrics.port;

import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;



@FunctionalInterface
public interface LoadFunctionalMetricsPort {

    FunctionalMetricsResponse loadFunctionalMetrics();
}
