package br.com.worklink.application.professional.usecase;

import java.util.UUID;

public record RequestProfessionalPhoneVerificationRequest(
        UUID professionalIdentifier
) {
}

