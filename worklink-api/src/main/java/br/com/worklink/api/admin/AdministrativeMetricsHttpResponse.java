package br.com.worklink.api.admin;

import br.com.worklink.application.admin.usecase.AdministrativeMetricsResponse;

public record AdministrativeMetricsHttpResponse(
        long professionalCount,
        long blockedProfessionalCount,
        long professionalReportCount,
        long reviewAnalysisRequestCount,
        long serviceCategoryCount
) {

    static AdministrativeMetricsHttpResponse fromResponse(AdministrativeMetricsResponse administrativeMetricsResponse) {
        return new AdministrativeMetricsHttpResponse(
                administrativeMetricsResponse.professionalCount(),
                administrativeMetricsResponse.blockedProfessionalCount(),
                administrativeMetricsResponse.professionalReportCount(),
                administrativeMetricsResponse.reviewAnalysisRequestCount(),
                administrativeMetricsResponse.serviceCategoryCount()
        );
    }
}
