package br.com.worklink.api.admin;

public record ModerateProfessionalReportHttpRequest(
        String moderationStatus,
        String moderationDecision,
        String moderationNotes
) {
}
