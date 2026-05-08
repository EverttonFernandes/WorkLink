package br.com.worklink.api.professional;

import java.util.UUID;

public record CompleteProfessionalProfileHttpRequest(
        UUID profilePhotoFileIdentifier,
        String documentNumber,
        String usefulLink,
        String portfolioDescription,
        String serviceDescription
) {
}
