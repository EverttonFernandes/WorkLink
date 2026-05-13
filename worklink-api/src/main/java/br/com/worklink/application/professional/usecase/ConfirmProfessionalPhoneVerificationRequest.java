package br.com.worklink.application.professional.usecase;

import java.util.UUID;

public record ConfirmProfessionalPhoneVerificationRequest(
        UUID professionalIdentifier,
        String verificationCode
) {
}

