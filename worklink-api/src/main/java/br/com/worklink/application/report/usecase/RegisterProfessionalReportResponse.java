package br.com.worklink.application.report.usecase;

import br.com.worklink.domain.report.ProfessionalReport;

import java.time.Instant;
import java.util.UUID;

public record RegisterProfessionalReportResponse(
        UUID professionalReportIdentifier,
        UUID professionalIdentifier,
        UUID reporterIdentifier,
        String reportReason,
        String description,
        UUID evidenceFileIdentifier,
        boolean seriousCase,
        String authorityGuidance,
        Instant createdAt
) {

    static RegisterProfessionalReportResponse fromProfessionalReport(ProfessionalReport professionalReport) {
        return new RegisterProfessionalReportResponse(
                professionalReport.professionalReportIdentifier(),
                professionalReport.professionalIdentifier(),
                professionalReport.reporterIdentifier(),
                professionalReport.reportReason().name(),
                professionalReport.description(),
                professionalReport.evidenceFileIdentifier(),
                professionalReport.seriousCase(),
                professionalReport.authorityGuidance(),
                professionalReport.createdAt()
        );
    }
}
