package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.ListProfessionalPortfolioItemsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPortfolioItemPort;
import br.com.worklink.application.storage.port.LoadStoredFileMetadataPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.professional.ProfessionalPortfolioItem;
import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFilePurpose;

public class AddProfessionalPortfolioItemUseCase {

    private static final int MAXIMUM_ACTIVE_PORTFOLIO_ITEMS = 10;

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final LoadStoredFileMetadataPort loadStoredFileMetadataPort;
    private final ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort;
    private final SaveProfessionalPortfolioItemPort saveProfessionalPortfolioItemPort;

    public AddProfessionalPortfolioItemUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            LoadStoredFileMetadataPort loadStoredFileMetadataPort,
            ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort,
            SaveProfessionalPortfolioItemPort saveProfessionalPortfolioItemPort
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.loadStoredFileMetadataPort = loadStoredFileMetadataPort;
        this.listProfessionalPortfolioItemsPort = listProfessionalPortfolioItemsPort;
        this.saveProfessionalPortfolioItemPort = saveProfessionalPortfolioItemPort;
    }

    public ProfessionalPortfolioItemResponse addProfessionalPortfolioItem(AddProfessionalPortfolioItemRequest request) {
        ensureProfessionalExists(request);
        StoredFile portfolioStoredFile = loadStoredFileMetadataPort
                .loadStoredFileMetadata(request.fileIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException(
                        "O arquivo de portfolio informado nao foi encontrado."
                ));
        ensureStoredFileCanBeUsedAsProfessionalPortfolio(portfolioStoredFile);
        ensurePortfolioItemLimitWasNotReached(request);
        try {
            ProfessionalPortfolioItem professionalPortfolioItem =
                    ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                            request.professionalIdentifier(),
                            request.fileIdentifier(),
                            request.title(),
                            request.description(),
                            request.displayOrder()
                    );
            return ProfessionalPortfolioItemResponse.fromPortfolioItem(
                    saveProfessionalPortfolioItemPort.saveProfessionalPortfolioItem(professionalPortfolioItem)
            );
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }

    private void ensureProfessionalExists(AddProfessionalPortfolioItemRequest request) {
        loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException(
                        "O profissional informado nao foi encontrado."
                ));
    }

    private void ensureStoredFileCanBeUsedAsProfessionalPortfolio(StoredFile portfolioStoredFile) {
        if (portfolioStoredFile.filePurpose() != StoredFilePurpose.PROFESSIONAL_PORTFOLIO
                || !portfolioStoredFile.isPubliclyReadable()) {
            throw new ApplicationRuleViolationException(
                    "O arquivo informado nao pode ser usado como portfolio profissional."
            );
        }
    }

    private void ensurePortfolioItemLimitWasNotReached(AddProfessionalPortfolioItemRequest request) {
        int activePortfolioItemCount = listProfessionalPortfolioItemsPort
                .listActiveProfessionalPortfolioItems(request.professionalIdentifier())
                .size();
        if (activePortfolioItemCount >= MAXIMUM_ACTIVE_PORTFOLIO_ITEMS) {
            throw new ApplicationRuleViolationException("O portfolio profissional atingiu o limite de itens.");
        }
    }
}
