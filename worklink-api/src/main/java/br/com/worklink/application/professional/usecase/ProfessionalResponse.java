package br.com.worklink.application.professional.usecase;

import br.com.worklink.domain.professional.Professional;

import java.util.UUID;

public record ProfessionalResponse(
        UUID professionalIdentifier,
        String professionalName,
        String whatsappNumber,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription,
        UUID profilePhotoFileIdentifier,
        String documentNumberHash,
        String usefulLink,
        String portfolioDescription,
        String serviceDescription,
        int profileCompletenessPercentage,
        String profileClassification,
        String availabilityStatus,
        String availabilityBadgeLabel,
        boolean availabilityReducesListingHighlight,
        boolean qualityGuarantee
) {

    static ProfessionalResponse fromProfessional(Professional professional) {
        return new ProfessionalResponse(
                professional.professionalIdentifier(),
                professional.professionalName(),
                professional.whatsappNumber(),
                professional.cityIdentifier(),
                professional.categoryIdentifier(),
                professional.shortDescription(),
                professional.profilePhotoFileIdentifier(),
                professional.documentNumberHash(),
                professional.usefulLink(),
                professional.portfolioDescription(),
                professional.serviceDescription(),
                professional.profileCompletenessPercentage(),
                professional.profileClassification().name(),
                professional.availabilityStatus().name(),
                professional.availabilityStatus().badgeLabel(),
                professional.availabilityStatus().reducesListingHighlight(),
                professional.qualityGuarantee()
        );
    }
}
