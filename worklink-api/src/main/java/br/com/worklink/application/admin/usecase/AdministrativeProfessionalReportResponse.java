package br.com.worklink.application.admin.usecase;

import br.com.worklink.domain.report.ProfessionalReport;

import java.time.Instant;
import java.util.UUID;

public record AdministrativeProfessionalReportResponse(
        UUID professionalReportIdentifier,
        UUID professionalIdentifier,
        String reportReason,
        boolean seriousCase,
        UUID evidenceFileIdentifier,
        Instant createdAt
) {

    static AdministrativeProfessionalReportResponse fromProfessionalReport(ProfessionalReport professionalReport) {
        return new AdministrativeProfessionalReportResponse(
                professionalReport.professionalReportIdentifier(),
                professionalReport.professionalIdentifier(),
                professionalReport.reportReason().name(),
                professionalReport.seriousCase(),
                professionalReport.evidenceFileIdentifier(),
                professionalReport.createdAt()
        );
    }
}
