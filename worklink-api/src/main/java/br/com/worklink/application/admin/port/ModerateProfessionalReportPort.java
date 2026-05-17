package br.com.worklink.application.admin.port;

import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.report.ProfessionalReport;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface ModerateProfessionalReportPort {

    Optional<ProfessionalReport> moderateProfessionalReport(
            UUID professionalReportIdentifier,
            ModerationStatus moderationStatus,
            ModerationDecision moderationDecision,
            String moderationNotes,
            Instant decidedAt
    );
}
