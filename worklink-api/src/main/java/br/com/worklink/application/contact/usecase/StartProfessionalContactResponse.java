package br.com.worklink.application.contact.usecase;

import java.time.Instant;
import java.util.UUID;

public record StartProfessionalContactResponse(
        UUID contactIntentIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        String whatsappContactLink,
        Instant createdAt
) {
}
