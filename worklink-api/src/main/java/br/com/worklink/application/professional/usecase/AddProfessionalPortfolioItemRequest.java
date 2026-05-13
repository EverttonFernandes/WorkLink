package br.com.worklink.application.professional.usecase;

import java.util.UUID;

public record AddProfessionalPortfolioItemRequest(
        UUID professionalIdentifier,
        UUID fileIdentifier,
        String title,
        String description,
        int displayOrder
) {
}
