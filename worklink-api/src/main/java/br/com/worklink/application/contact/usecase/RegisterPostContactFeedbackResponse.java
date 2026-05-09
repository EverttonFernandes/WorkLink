package br.com.worklink.application.contact.usecase;

import java.time.Instant;
import java.util.UUID;

public record RegisterPostContactFeedbackResponse(
        UUID postContactFeedbackIdentifier,
        UUID contactIntentIdentifier,
        String conversationOutcome,
        String contactResponsiveness,
        String serviceExecutionOutcome,
        Instant createdAt
) {
}
