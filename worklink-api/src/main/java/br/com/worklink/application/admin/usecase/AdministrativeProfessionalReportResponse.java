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
        String moderationStatus,
        String moderationDecision,
        String moderationNotes,
        Instant decidedAt,
        Instant createdAt
) {

    static AdministrativeProfessionalReportResponse fromProfessionalReport(ProfessionalReport professionalReport) {
        return new AdministrativeProfessionalReportResponse(
                professionalReport.professionalReportIdentifier(),
                professionalReport.professionalIdentifier(),
                professionalReport.reportReason().name(),
                professionalReport.seriousCase(),
                professionalReport.evidenceFileIdentifier(),
                professionalReport.moderationStatus().name(),
                professionalReport.moderationDecision() == null ? null : professionalReport.moderationDecision().name(),
                professionalReport.moderationNotes(),
                professionalReport.decidedAt(),
                professionalReport.createdAt()
        );
    }
}
