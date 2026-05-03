package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.professional.Professional;

public class RegisterBasicProfessionalUseCase {

    private final LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort;
    private final LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort;
    private final SaveProfessionalPort saveProfessionalPort;

    public RegisterBasicProfessionalUseCase(
            LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort,
            LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort,
            SaveProfessionalPort saveProfessionalPort
    ) {
        this.loadServiceCityByIdentifierPort = loadServiceCityByIdentifierPort;
        this.loadServiceCategoryByIdentifierPort = loadServiceCategoryByIdentifierPort;
        this.saveProfessionalPort = saveProfessionalPort;
    }

    public ProfessionalResponse registerBasicProfessional(RegisterBasicProfessionalRequest request) {
        try {
            Professional professional = Professional.registerBasicProfessional(
                    request.professionalName(),
                    request.whatsappNumber(),
                    request.cityIdentifier(),
                    request.categoryIdentifier(),
                    request.shortDescription()
            );
            ensureCityExists(professional);
            ensureCategoryExists(professional);
            return ProfessionalResponse.fromProfessional(saveProfessionalPort.saveProfessional(professional));
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }

    private void ensureCityExists(Professional professional) {
        if (loadServiceCityByIdentifierPort.loadServiceCityByIdentifier(professional.cityIdentifier()).isEmpty()) {
            throw new ApplicationRuleViolationException("A cidade informada para o profissional nao foi encontrada.");
        }
    }

    private void ensureCategoryExists(Professional professional) {
        if (loadServiceCategoryByIdentifierPort.loadServiceCategoryByIdentifier(professional.categoryIdentifier()).isEmpty()) {
            throw new ApplicationRuleViolationException("A categoria informada para o profissional nao foi encontrada.");
        }
    }
}
