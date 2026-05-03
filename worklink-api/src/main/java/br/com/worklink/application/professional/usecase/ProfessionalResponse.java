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
        String profileClassification,
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
                professional.profileClassification().name(),
                professional.qualityGuarantee()
        );
    }
}
