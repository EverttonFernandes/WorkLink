package br.com.worklink.api.professional;

import br.com.worklink.application.professional.usecase.ProfessionalResponse;

import java.util.UUID;

public record ProfessionalHttpResponse(
        UUID professionalIdentifier,
        String professionalName,
        String whatsappNumber,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription,
        UUID profilePhotoFileIdentifier,
        boolean documentProvided,
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

    static ProfessionalHttpResponse fromProfessionalResponse(ProfessionalResponse professionalResponse) {
        return new ProfessionalHttpResponse(
                professionalResponse.professionalIdentifier(),
                professionalResponse.professionalName(),
                professionalResponse.whatsappNumber(),
                professionalResponse.cityIdentifier(),
                professionalResponse.categoryIdentifier(),
                professionalResponse.shortDescription(),
                professionalResponse.profilePhotoFileIdentifier(),
                professionalResponse.documentNumberHash() != null,
                professionalResponse.usefulLink(),
                professionalResponse.portfolioDescription(),
                professionalResponse.serviceDescription(),
                professionalResponse.profileCompletenessPercentage(),
                professionalResponse.profileClassification(),
                professionalResponse.availabilityStatus(),
                professionalResponse.availabilityBadgeLabel(),
                professionalResponse.availabilityReducesListingHighlight(),
                professionalResponse.qualityGuarantee()
        );
    }
}
