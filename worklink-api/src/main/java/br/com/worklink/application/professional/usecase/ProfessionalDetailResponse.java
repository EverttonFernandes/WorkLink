package br.com.worklink.application.professional.usecase;

import br.com.worklink.domain.professional.Professional;

import java.util.UUID;

public record ProfessionalDetailResponse(
        UUID professionalIdentifier,
        String professionalName,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription,
        UUID profilePhotoFileIdentifier,
        String usefulLink,
        String portfolioDescription,
        String serviceDescription,
        String profileClassification,
        String availabilityStatus,
        String availabilityBadgeLabel,
        boolean availabilityReducesListingHighlight,
        boolean phoneNumberVerified,
        boolean qualityGuarantee
) {

    static ProfessionalDetailResponse fromProfessional(Professional professional) {
        return new ProfessionalDetailResponse(
                professional.professionalIdentifier(),
                professional.professionalName(),
                professional.cityIdentifier(),
                professional.categoryIdentifier(),
                professional.shortDescription(),
                professional.profilePhotoFileIdentifier(),
                professional.usefulLink(),
                professional.portfolioDescription(),
                professional.serviceDescription(),
                professional.profileClassification().name(),
                professional.availabilityStatus().name(),
                professional.availabilityStatus().badgeLabel(),
                professional.availabilityStatus().reducesListingHighlight(),
                professional.phoneNumberVerified(),
                professional.qualityGuarantee()
        );
    }
}
