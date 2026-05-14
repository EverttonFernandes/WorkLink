package br.com.worklink.api.admin;

public record ModerateReviewAnalysisRequestHttpRequest(
        String moderationStatus,
        String moderationDecision,
        String moderationNotes
) {
}
