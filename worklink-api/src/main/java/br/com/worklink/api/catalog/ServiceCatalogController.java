package br.com.worklink.api.catalog;

import br.com.worklink.application.catalog.usecase.ListServiceCategoriesUseCase;
import br.com.worklink.application.catalog.usecase.ListServiceCitiesUseCase;
import br.com.worklink.application.catalog.usecase.RegisterServiceCategoryRequest;
import br.com.worklink.application.catalog.usecase.RegisterServiceCategoryUseCase;
import br.com.worklink.application.catalog.usecase.RegisterServiceCityRequest;
import br.com.worklink.application.catalog.usecase.RegisterServiceCityUseCase;
import br.com.worklink.application.catalog.usecase.ServiceCategoryResponse;
import br.com.worklink.application.catalog.usecase.ServiceCityResponse;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ServiceCatalogController {

    private final RegisterServiceCategoryUseCase registerServiceCategoryUseCase;
    private final ListServiceCategoriesUseCase listServiceCategoriesUseCase;
    private final RegisterServiceCityUseCase registerServiceCityUseCase;
    private final ListServiceCitiesUseCase listServiceCitiesUseCase;

    public ServiceCatalogController(
            RegisterServiceCategoryUseCase registerServiceCategoryUseCase,
            ListServiceCategoriesUseCase listServiceCategoriesUseCase,
            RegisterServiceCityUseCase registerServiceCityUseCase,
            ListServiceCitiesUseCase listServiceCitiesUseCase
    ) {
        this.registerServiceCategoryUseCase = registerServiceCategoryUseCase;
        this.listServiceCategoriesUseCase = listServiceCategoriesUseCase;
        this.registerServiceCityUseCase = registerServiceCityUseCase;
        this.listServiceCitiesUseCase = listServiceCitiesUseCase;
    }

    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    ServiceCategoryHttpResponse registerServiceCategory(@RequestBody RegisterServiceCategoryHttpRequest request) {
        ServiceCategoryResponse serviceCategoryResponse = registerServiceCategoryUseCase.registerServiceCategory(
                new RegisterServiceCategoryRequest(request.categoryName())
        );
        return ServiceCategoryHttpResponse.fromServiceCategoryResponse(serviceCategoryResponse);
    }

    @GetMapping("/categories")
    List<ServiceCategoryHttpResponse> listServiceCategories() {
        return listServiceCategoriesUseCase.listServiceCategories().stream()
                .map(ServiceCategoryHttpResponse::fromServiceCategoryResponse)
                .toList();
    }

    @PostMapping("/cities")
    @ResponseStatus(HttpStatus.CREATED)
    ServiceCityHttpResponse registerServiceCity(@RequestBody RegisterServiceCityHttpRequest request) {
        ServiceCityResponse serviceCityResponse = registerServiceCityUseCase.registerServiceCity(
                new RegisterServiceCityRequest(request.cityName(), request.stateCode())
        );
        return ServiceCityHttpResponse.fromServiceCityResponse(serviceCityResponse);
    }

    @GetMapping("/cities")
    List<ServiceCityHttpResponse> listServiceCities() {
        return listServiceCitiesUseCase.listServiceCities().stream()
                .map(ServiceCityHttpResponse::fromServiceCityResponse)
                .toList();
    }
}
