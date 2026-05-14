package br.com.worklink.application.contact.port;

import java.time.Instant;
import java.util.UUID;

public record PostContactFeedbackRequestProjection(
        UUID contactIntentIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        Instant contactCreatedAt
) {
}
