package br.com.worklink.application.professional.port;

import br.com.worklink.domain.professional.ProfessionalPortfolioItem;

import java.util.List;
import java.util.UUID;

@FunctionalInterface
public interface ListProfessionalPortfolioItemsPort {

    List<ProfessionalPortfolioItem> listActiveProfessionalPortfolioItems(UUID professionalIdentifier);
}
