package br.com.worklink.domain.report;

import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;

import java.time.Instant;
import java.util.UUID;

public record ProfessionalReport(
        UUID professionalReportIdentifier,
        UUID professionalIdentifier,
        UUID reporterIdentifier,
        ProfessionalReportReason reportReason,
        String description,
        UUID evidenceFileIdentifier,
        boolean seriousCase,
        String authorityGuidance,
        ModerationStatus moderationStatus,
        ModerationDecision moderationDecision,
        String moderationNotes,
        Instant decidedAt,
        Instant createdAt
) {

    private static final String SERIOUS_CASE_AUTHORITY_GUIDANCE =
            "Em caso de risco, ameaca ou violencia, busque autoridades competentes imediatamente.";

    public static ProfessionalReport registerProfessionalReport(
            UUID professionalIdentifier,
            UUID reporterIdentifier,
            ProfessionalReportReason reportReason,
            String description,
            UUID evidenceFileIdentifier,
            Instant createdAt
    ) {
        ProfessionalReportReason validReportReason = requireReportReason(reportReason);
        return new ProfessionalReport(
                UUID.randomUUID(),
                requireIdentifier(professionalIdentifier, "O profissional denunciado e obrigatorio."),
                requireIdentifier(reporterIdentifier, "O autor da denuncia e obrigatorio."),
                validReportReason,
                normalizeDescription(description),
                evidenceFileIdentifier,
                validReportReason.isSerious(),
                guidanceForReason(validReportReason),
                ModerationStatus.PENDING,
                null,
                null,
                null,
                requireCreatedAt(createdAt)
        );
    }

    public static ProfessionalReport restoreProfessionalReport(
            UUID professionalReportIdentifier,
            UUID professionalIdentifier,
            UUID reporterIdentifier,
            ProfessionalReportReason reportReason,
            String description,
            UUID evidenceFileIdentifier,
            boolean seriousCase,
            String authorityGuidance,
            ModerationStatus moderationStatus,
            ModerationDecision moderationDecision,
            String moderationNotes,
            Instant decidedAt,
            Instant createdAt
    ) {
        return new ProfessionalReport(
                requireIdentifier(professionalReportIdentifier, "O identificador da denuncia e obrigatorio."),
                requireIdentifier(professionalIdentifier, "O profissional denunciado e obrigatorio."),
                requireIdentifier(reporterIdentifier, "O autor da denuncia e obrigatorio."),
                requireReportReason(reportReason),
                normalizeDescription(description),
                evidenceFileIdentifier,
                seriousCase,
                normalizeDescription(authorityGuidance),
                requireModerationStatus(moderationStatus),
                moderationDecision,
                normalizeDescription(moderationNotes),
                decidedAt,
                requireCreatedAt(createdAt)
        );
    }

    private static ProfessionalReportReason requireReportReason(ProfessionalReportReason reportReason) {
        if (reportReason == null) {
            throw new BusinessRuleViolationException("O motivo da denuncia e obrigatorio.");
        }
        return reportReason;
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static String normalizeDescription(String description) {
        if (description == null || description.isBlank()) {
            return null;
        }
        return description.trim();
    }

    private static String guidanceForReason(ProfessionalReportReason reportReason) {
        if (!reportReason.isSerious()) {
            return null;
        }
        return SERIOUS_CASE_AUTHORITY_GUIDANCE;
    }

    private static Instant requireCreatedAt(Instant createdAt) {
        if (createdAt == null) {
            throw new BusinessRuleViolationException("O momento da denuncia e obrigatorio.");
        }
        return createdAt;
    }

    private static ModerationStatus requireModerationStatus(ModerationStatus moderationStatus) {
        if (moderationStatus == null) {
            throw new BusinessRuleViolationException("O status de moderacao da denuncia e obrigatorio.");
        }
        return moderationStatus;
    }
}
