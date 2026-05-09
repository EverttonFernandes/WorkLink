package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.admin.port.LoadAdministrativeMetricsPort;

public class LoadAdministrativeMetricsUseCase {

    private final LoadAdministrativeMetricsPort loadAdministrativeMetricsPort;

    public LoadAdministrativeMetricsUseCase(LoadAdministrativeMetricsPort loadAdministrativeMetricsPort) {
        this.loadAdministrativeMetricsPort = loadAdministrativeMetricsPort;
    }

    public AdministrativeMetricsResponse loadAdministrativeMetrics() {
        return new AdministrativeMetricsResponse(
                loadAdministrativeMetricsPort.countProfessionals(),
                loadAdministrativeMetricsPort.countBlockedProfessionals(),
                loadAdministrativeMetricsPort.countProfessionalReports(),
                loadAdministrativeMetricsPort.countReviewAnalysisRequests(),
                loadAdministrativeMetricsPort.countServiceCategories()
        );
    }
}
