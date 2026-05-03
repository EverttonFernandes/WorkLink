package br.com.worklink.application.professional.usecase;

import java.util.UUID;

public record RegisterBasicProfessionalRequest(
        String professionalName,
        String whatsappNumber,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription
) {
}
