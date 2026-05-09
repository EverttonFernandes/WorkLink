package br.com.worklink.api.admin;

import br.com.worklink.application.admin.usecase.AdministrativeProfessionalResponse;

import java.util.UUID;

public record AdministrativeProfessionalHttpResponse(
        UUID professionalIdentifier,
        String professionalName,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String profileClassification,
        String availabilityStatus,
        boolean blocked
) {

    static AdministrativeProfessionalHttpResponse fromResponse(
            AdministrativeProfessionalResponse administrativeProfessionalResponse
    ) {
        return new AdministrativeProfessionalHttpResponse(
                administrativeProfessionalResponse.professionalIdentifier(),
                administrativeProfessionalResponse.professionalName(),
                administrativeProfessionalResponse.cityIdentifier(),
                administrativeProfessionalResponse.categoryIdentifier(),
                administrativeProfessionalResponse.profileClassification(),
                administrativeProfessionalResponse.availabilityStatus(),
                administrativeProfessionalResponse.blocked()
        );
    }
}
