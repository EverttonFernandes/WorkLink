package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.professional.port.ListProfessionalPortfolioItemsPort;

import java.util.List;
import java.util.UUID;

public class ListProfessionalPortfolioItemsUseCase {

    private final ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort;

    public ListProfessionalPortfolioItemsUseCase(ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort) {
        this.listProfessionalPortfolioItemsPort = listProfessionalPortfolioItemsPort;
    }

    public List<ProfessionalPortfolioItemResponse> listProfessionalPortfolioItems(UUID professionalIdentifier) {
        return listProfessionalPortfolioItemsPort.listActiveProfessionalPortfolioItems(professionalIdentifier)
                .stream()
                .map(ProfessionalPortfolioItemResponse::fromPortfolioItem)
                .toList();
    }
}
