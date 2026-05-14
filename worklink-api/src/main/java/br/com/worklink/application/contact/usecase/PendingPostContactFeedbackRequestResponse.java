package br.com.worklink.application.contact.usecase;

import java.time.Instant;
import java.util.UUID;

public record PendingPostContactFeedbackRequestResponse(
        UUID contactIntentIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        Instant contactCreatedAt
) {
}
