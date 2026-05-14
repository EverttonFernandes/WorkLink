package br.com.worklink.application.admin.usecase;

import java.util.UUID;

public record ModerateProfessionalReportRequest(
        UUID professionalReportIdentifier,
        String moderationStatus,
        String moderationDecision,
        String moderationNotes
) {
}
