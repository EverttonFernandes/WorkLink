package br.com.worklink.application.professional.usecase;

import java.util.UUID;

public record CompleteProfessionalProfileRequest(
        UUID professionalIdentifier,
        UUID profilePhotoFileIdentifier,
        String documentNumber,
        String usefulLink,
        String portfolioDescription,
        String serviceDescription,
        String availabilityStatus
) {
}
