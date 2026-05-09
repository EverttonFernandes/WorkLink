package br.com.worklink.application.admin.port;

public interface LoadAdministrativeMetricsPort {

    long countProfessionals();

    long countBlockedProfessionals();

    long countProfessionalReports();

    long countReviewAnalysisRequests();

    long countServiceCategories();
}
