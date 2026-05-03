package br.com.worklink.application.catalog.usecase;

import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.catalog.ServiceCategory;

public class RegisterServiceCategoryUseCase {

    private final SaveServiceCategoryPort saveServiceCategoryPort;

    public RegisterServiceCategoryUseCase(SaveServiceCategoryPort saveServiceCategoryPort) {
        this.saveServiceCategoryPort = saveServiceCategoryPort;
    }

    public ServiceCategoryResponse registerServiceCategory(RegisterServiceCategoryRequest request) {
        try {
            ServiceCategory serviceCategory = ServiceCategory.createServiceCategory(request.categoryName());
            return ServiceCategoryResponse.fromServiceCategory(saveServiceCategoryPort.saveServiceCategory(serviceCategory));
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }
}
