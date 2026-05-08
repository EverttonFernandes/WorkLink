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
                professionalResponse.documentNumber() != null,
                professionalResponse.usefulLink(),
                professionalResponse.portfolioDescription(),
                professionalResponse.serviceDescription(),
                professionalResponse.profileCompletenessPercentage(),
                professionalResponse.profileClassification(),
                professionalResponse.qualityGuarantee()
        );
    }
}
