package br.com.worklink.application.catalog.usecase;

import br.com.worklink.domain.catalog.ServiceCategory;

import java.util.UUID;

public record ServiceCategoryResponse(
        UUID categoryIdentifier,
        String categoryName,
        String categorySlug
) {

    static ServiceCategoryResponse fromServiceCategory(ServiceCategory serviceCategory) {
        return new ServiceCategoryResponse(
                serviceCategory.categoryIdentifier(),
                serviceCategory.categoryName(),
                serviceCategory.categorySlug()
        );
    }
}
