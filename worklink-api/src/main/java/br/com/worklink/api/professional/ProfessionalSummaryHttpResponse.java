package br.com.worklink.api.professional;

import br.com.worklink.application.professional.usecase.ProfessionalSummaryResponse;

import java.util.UUID;

public record ProfessionalSummaryHttpResponse(
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

    static ProfessionalSummaryHttpResponse fromProfessionalSummaryResponse(
            ProfessionalSummaryResponse professionalSummaryResponse
    ) {
        return new ProfessionalSummaryHttpResponse(
                professionalSummaryResponse.professionalIdentifier(),
                professionalSummaryResponse.professionalName(),
                professionalSummaryResponse.cityIdentifier(),
                professionalSummaryResponse.categoryIdentifier(),
                professionalSummaryResponse.shortDescription(),
                professionalSummaryResponse.profilePhotoFileIdentifier(),
                professionalSummaryResponse.availabilityStatus(),
                professionalSummaryResponse.availabilityBadgeLabel(),
                professionalSummaryResponse.availabilityReducesListingHighlight(),
                professionalSummaryResponse.phoneNumberVerified(),
                professionalSummaryResponse.qualityGuarantee()
        );
    }
}
