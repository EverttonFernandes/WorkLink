package br.com.worklink.application.metrics.usecase;

import br.com.worklink.application.metrics.port.LoadFunctionalMetricsPort;

public class LoadFunctionalMetricsUseCase {

    private final LoadFunctionalMetricsPort loadFunctionalMetricsPort;

    public LoadFunctionalMetricsUseCase(LoadFunctionalMetricsPort loadFunctionalMetricsPort) {
        this.loadFunctionalMetricsPort = loadFunctionalMetricsPort;
    }

    public FunctionalMetricsResponse loadFunctionalMetrics() {
        return loadFunctionalMetricsPort.loadFunctionalMetrics();
    }
}
