package br.com.worklink.api.professional;

import java.util.UUID;

public record AddProfessionalPortfolioItemHttpRequest(
        UUID fileIdentifier,
        String title,
        String description,
        int displayOrder
) {
}
