package br.com.worklink.api.catalog;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
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
import org.springframework.web.bind.annotation.RequestHeader;
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
    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;

    public ServiceCatalogController(
            RegisterServiceCategoryUseCase registerServiceCategoryUseCase,
            ListServiceCategoriesUseCase listServiceCategoriesUseCase,
            RegisterServiceCityUseCase registerServiceCityUseCase,
            ListServiceCitiesUseCase listServiceCitiesUseCase,
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase
    ) {
        this.registerServiceCategoryUseCase = registerServiceCategoryUseCase;
        this.listServiceCategoriesUseCase = listServiceCategoriesUseCase;
        this.registerServiceCityUseCase = registerServiceCityUseCase;
        this.listServiceCitiesUseCase = listServiceCitiesUseCase;
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.authorizeSensitiveActionUseCase = authorizeSensitiveActionUseCase;
    }

    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    ServiceCategoryHttpResponse registerServiceCategory(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody RegisterServiceCategoryHttpRequest request
    ) {
        authorizeSensitiveActionUseCase.authorizeSensitiveAction(
                authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(authorizationHeader),
                SensitiveAction.REGISTER_SERVICE_CATEGORY
        );
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
    ServiceCityHttpResponse registerServiceCity(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody RegisterServiceCityHttpRequest request
    ) {
        authorizeSensitiveActionUseCase.authorizeSensitiveAction(
                authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(authorizationHeader),
                SensitiveAction.REGISTER_SERVICE_CITY
        );
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
