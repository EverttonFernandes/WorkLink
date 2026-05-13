package br.com.worklink.application.professional.usecase;

import java.time.Instant;
import java.util.UUID;

public record RequestProfessionalPhoneVerificationResponse(
        UUID professionalIdentifier,
        String message,
        Instant expiresAt
) {
}
