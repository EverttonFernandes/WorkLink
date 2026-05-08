package br.com.worklink.api.catalog;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
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
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public ServiceCatalogController(
            RegisterServiceCategoryUseCase registerServiceCategoryUseCase,
            ListServiceCategoriesUseCase listServiceCategoriesUseCase,
            RegisterServiceCityUseCase registerServiceCityUseCase,
            ListServiceCitiesUseCase listServiceCitiesUseCase,
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.registerServiceCategoryUseCase = registerServiceCategoryUseCase;
        this.listServiceCategoriesUseCase = listServiceCategoriesUseCase;
        this.registerServiceCityUseCase = registerServiceCityUseCase;
        this.listServiceCitiesUseCase = listServiceCitiesUseCase;
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.authorizeSensitiveActionUseCase = authorizeSensitiveActionUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    ServiceCategoryHttpResponse registerServiceCategory(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody RegisterServiceCategoryHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        authorizeSensitiveActionUseCase.authorizeSensitiveAction(
                authenticatedPrincipal,
                SensitiveAction.REGISTER_SERVICE_CATEGORY
        );
        ServiceCategoryResponse serviceCategoryResponse = registerServiceCategoryUseCase.registerServiceCategory(
                new RegisterServiceCategoryRequest(request.categoryName())
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REGISTER_SERVICE_CATEGORY,
                SensitiveAuditTargetType.SERVICE_CATEGORY,
                serviceCategoryResponse.categoryIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
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
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        authorizeSensitiveActionUseCase.authorizeSensitiveAction(
                authenticatedPrincipal,
                SensitiveAction.REGISTER_SERVICE_CITY
        );
        ServiceCityResponse serviceCityResponse = registerServiceCityUseCase.registerServiceCity(
                new RegisterServiceCityRequest(request.cityName(), request.stateCode())
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REGISTER_SERVICE_CITY,
                SensitiveAuditTargetType.SERVICE_CITY,
                serviceCityResponse.cityIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
        return ServiceCityHttpResponse.fromServiceCityResponse(serviceCityResponse);
    }

    @GetMapping("/cities")
    List<ServiceCityHttpResponse> listServiceCities() {
        return listServiceCitiesUseCase.listServiceCities().stream()
                .map(ServiceCityHttpResponse::fromServiceCityResponse)
                .toList();
    }
}
