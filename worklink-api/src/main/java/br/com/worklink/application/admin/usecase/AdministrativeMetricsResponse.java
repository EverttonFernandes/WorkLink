package br.com.worklink.application.admin.usecase;

public record AdministrativeMetricsResponse(
        long professionalCount,
        long blockedProfessionalCount,
        long professionalReportCount,
        long reviewAnalysisRequestCount,
        long serviceCategoryCount
) {
}
