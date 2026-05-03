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
                professionalResponse.profileClassification(),
                professionalResponse.qualityGuarantee()
        );
    }
}
