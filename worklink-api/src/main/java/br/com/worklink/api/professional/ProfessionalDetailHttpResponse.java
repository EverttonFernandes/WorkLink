package br.com.worklink.api.professional;

import br.com.worklink.application.professional.usecase.ProfessionalDetailResponse;

import java.util.UUID;

public record ProfessionalDetailHttpResponse(
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

    static ProfessionalDetailHttpResponse fromProfessionalDetailResponse(
            ProfessionalDetailResponse professionalDetailResponse
    ) {
        return new ProfessionalDetailHttpResponse(
                professionalDetailResponse.professionalIdentifier(),
                professionalDetailResponse.professionalName(),
                professionalDetailResponse.cityIdentifier(),
                professionalDetailResponse.categoryIdentifier(),
                professionalDetailResponse.shortDescription(),
                professionalDetailResponse.profilePhotoFileIdentifier(),
                professionalDetailResponse.usefulLink(),
                professionalDetailResponse.portfolioDescription(),
                professionalDetailResponse.serviceDescription(),
                professionalDetailResponse.profileClassification(),
                professionalDetailResponse.availabilityStatus(),
                professionalDetailResponse.availabilityBadgeLabel(),
                professionalDetailResponse.availabilityReducesListingHighlight(),
                professionalDetailResponse.phoneNumberVerified(),
                professionalDetailResponse.qualityGuarantee()
        );
    }
}
