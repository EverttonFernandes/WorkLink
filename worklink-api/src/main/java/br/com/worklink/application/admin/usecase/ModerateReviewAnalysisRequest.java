package br.com.worklink.application.admin.usecase;

import java.util.UUID;

public record ModerateReviewAnalysisRequest(
        UUID reviewAnalysisRequestIdentifier,
        String moderationStatus,
        String moderationDecision,
        String moderationNotes
) {
}
