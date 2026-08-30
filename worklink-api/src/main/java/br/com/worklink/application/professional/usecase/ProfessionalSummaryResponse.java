package br.com.worklink.application.professional.usecase;

import br.com.worklink.domain.professional.Professional;

import java.util.UUID;

public record ProfessionalSummaryResponse(
        UUID professionalIdentifier,
        String professionalName,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription,
        UUID profilePhotoFileIdentifier,
        String availabilityStatus,
        String availabilityBadgeLabel,
        boolean availabilityReducesListingHighlight,
        boolean phoneNumberVerified,
        boolean qualityGuarantee
) {

    static ProfessionalSummaryResponse fromProfessional(Professional professional) {
        return new ProfessionalSummaryResponse(
                professional.professionalIdentifier(),
                professional.professionalName(),
                professional.cityIdentifier(),
                professional.categoryIdentifier(),
                professional.shortDescription(),
                professional.profilePhotoFileIdentifier(),
                professional.availabilityStatus().name(),
                professional.availabilityStatus().badgeLabel(),
                professional.availabilityStatus().reducesListingHighlight(),
                professional.phoneNumberVerified(),
                professional.qualityGuarantee()
        );
    }
}
