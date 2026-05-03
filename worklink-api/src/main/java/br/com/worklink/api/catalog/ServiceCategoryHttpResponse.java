package br.com.worklink.api.catalog;

import br.com.worklink.application.catalog.usecase.ServiceCategoryResponse;

import java.util.UUID;

public record ServiceCategoryHttpResponse(
        UUID categoryIdentifier,
        String categoryName,
        String categorySlug
) {

    static ServiceCategoryHttpResponse fromServiceCategoryResponse(ServiceCategoryResponse serviceCategoryResponse) {
        return new ServiceCategoryHttpResponse(
                serviceCategoryResponse.categoryIdentifier(),
                serviceCategoryResponse.categoryName(),
                serviceCategoryResponse.categorySlug()
        );
    }
}
