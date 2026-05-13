package br.com.worklink.application.professional.usecase;

import br.com.worklink.domain.professional.ProfessionalPortfolioItem;

import java.util.UUID;

public record ProfessionalPortfolioItemResponse(
        UUID portfolioItemIdentifier,
        UUID professionalIdentifier,
        UUID fileIdentifier,
        String title,
        String description,
        int displayOrder
) {

    static ProfessionalPortfolioItemResponse fromPortfolioItem(ProfessionalPortfolioItem professionalPortfolioItem) {
        return new ProfessionalPortfolioItemResponse(
                professionalPortfolioItem.portfolioItemIdentifier(),
                professionalPortfolioItem.professionalIdentifier(),
                professionalPortfolioItem.fileIdentifier(),
                professionalPortfolioItem.title(),
                professionalPortfolioItem.description(),
                professionalPortfolioItem.displayOrder()
        );
    }
}
