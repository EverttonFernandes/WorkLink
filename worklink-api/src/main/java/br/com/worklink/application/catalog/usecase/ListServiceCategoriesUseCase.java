package br.com.worklink.application.catalog.usecase;

import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import java.util.List;

public class ListServiceCategoriesUseCase {

    private final ListServiceCategoriesPort listServiceCategoriesPort;

    public ListServiceCategoriesUseCase(ListServiceCategoriesPort listServiceCategoriesPort) {
        this.listServiceCategoriesPort = listServiceCategoriesPort;
    }

    public List<ServiceCategoryResponse> listServiceCategories() {
        return listServiceCategoriesPort.listServiceCategories().stream()
                .map(ServiceCategoryResponse::fromServiceCategory)
                .toList();
    }
}
