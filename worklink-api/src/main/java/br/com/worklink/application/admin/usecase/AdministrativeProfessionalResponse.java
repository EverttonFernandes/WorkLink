package br.com.worklink.application.admin.usecase;

import br.com.worklink.domain.professional.Professional;

import java.util.UUID;

public record AdministrativeProfessionalResponse(
        UUID professionalIdentifier,
        String professionalName,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String profileClassification,
        String availabilityStatus,
        boolean blocked
) {

    static AdministrativeProfessionalResponse fromProfessional(Professional professional) {
        return new AdministrativeProfessionalResponse(
                professional.professionalIdentifier(),
                professional.professionalName(),
                professional.cityIdentifier(),
                professional.categoryIdentifier(),
                professional.profileClassification().name(),
                professional.availabilityStatus().name(),
                professional.blocked()
        );
    }
}
