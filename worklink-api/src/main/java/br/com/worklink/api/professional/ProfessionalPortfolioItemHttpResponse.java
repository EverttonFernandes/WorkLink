package br.com.worklink.api.professional;

import br.com.worklink.application.professional.usecase.ProfessionalPortfolioItemResponse;

import java.util.UUID;

public record ProfessionalPortfolioItemHttpResponse(
        UUID portfolioItemIdentifier,
        UUID professionalIdentifier,
        UUID fileIdentifier,
        String title,
        String description,
        int displayOrder
) {

    static ProfessionalPortfolioItemHttpResponse fromResponse(
            ProfessionalPortfolioItemResponse professionalPortfolioItemResponse
    ) {
        return new ProfessionalPortfolioItemHttpResponse(
                professionalPortfolioItemResponse.portfolioItemIdentifier(),
                professionalPortfolioItemResponse.professionalIdentifier(),
                professionalPortfolioItemResponse.fileIdentifier(),
                professionalPortfolioItemResponse.title(),
                professionalPortfolioItemResponse.description(),
                professionalPortfolioItemResponse.displayOrder()
        );
    }
}
