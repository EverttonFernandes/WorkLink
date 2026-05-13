package br.com.worklink.application.professional.port;

import br.com.worklink.domain.professional.ProfessionalPortfolioItem;

@FunctionalInterface
public interface SaveProfessionalPortfolioItemPort {

    ProfessionalPortfolioItem saveProfessionalPortfolioItem(ProfessionalPortfolioItem professionalPortfolioItem);
}
