package br.com.worklink.api;

import br.com.worklink.api.catalog.ServiceCatalogController;
import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
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

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ServiceCatalogController.class)
class ServiceCatalogControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-token";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private RegisterServiceCategoryUseCase registerServiceCategoryUseCase;

    @MockBean
    private ListServiceCategoriesUseCase listServiceCategoriesUseCase;

    @MockBean
    private RegisterServiceCityUseCase registerServiceCityUseCase;

    @MockBean
    private ListServiceCitiesUseCase listServiceCitiesUseCase;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("Deve expor cadastro de categoria de servico pela API")
    void shouldExposeServiceCategoryRegistrationThroughApi() throws Exception {
        // GIVEN
        ServiceCategoryResponse serviceCategoryResponse = new ServiceCategoryResponse(UUID.randomUUID(), "Eletricista", "eletricista");
        AuthenticatedPrincipal administratorPrincipal = administratorPrincipal();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER)).thenReturn(administratorPrincipal);
        when(registerServiceCategoryUseCase.registerServiceCategory(any(RegisterServiceCategoryRequest.class)))
                .thenReturn(serviceCategoryResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/categories")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCategoryBody("Eletricista"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.categoryIdentifier").value(serviceCategoryResponse.categoryIdentifier().toString()))
                .andExpect(jsonPath("$.categoryName").value("Eletricista"))
                .andExpect(jsonPath("$.categorySlug").value("eletricista"));
        verify(authorizeSensitiveActionUseCase).authorizeSensitiveAction(
                administratorPrincipal,
                SensitiveAction.REGISTER_SERVICE_CATEGORY
        );
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(administratorPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.REGISTER_SERVICE_CATEGORY
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.SERVICE_CATEGORY
                        && auditRequest.targetIdentifier().equals(serviceCategoryResponse.categoryIdentifier())
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("Deve expor listagem de categorias de servico pela API")
    void shouldExposeServiceCategoryListingThroughApi() throws Exception {
        // GIVEN
        ServiceCategoryResponse serviceCategoryResponse = new ServiceCategoryResponse(UUID.randomUUID(), "Pintor", "pintor");
        when(listServiceCategoriesUseCase.listServiceCategories()).thenReturn(List.of(serviceCategoryResponse));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/categories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].categoryName").value("Pintor"));
    }

    @Test
    @DisplayName("Deve expor cadastro de cidade de atendimento pela API")
    void shouldExposeServiceCityRegistrationThroughApi() throws Exception {
        // GIVEN
        ServiceCityResponse serviceCityResponse = new ServiceCityResponse(UUID.randomUUID(), "Canoas", "RS", "canoas-rs");
        AuthenticatedPrincipal administratorPrincipal = administratorPrincipal();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER)).thenReturn(administratorPrincipal);
        when(registerServiceCityUseCase.registerServiceCity(any(RegisterServiceCityRequest.class))).thenReturn(serviceCityResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/cities")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCityBody("Canoas", "RS"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.cityIdentifier").value(serviceCityResponse.cityIdentifier().toString()))
                .andExpect(jsonPath("$.cityName").value("Canoas"))
                .andExpect(jsonPath("$.stateCode").value("RS"))
                .andExpect(jsonPath("$.citySlug").value("canoas-rs"));
        verify(authorizeSensitiveActionUseCase).authorizeSensitiveAction(
                administratorPrincipal,
                SensitiveAction.REGISTER_SERVICE_CITY
        );
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(administratorPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.REGISTER_SERVICE_CITY
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.SERVICE_CITY
                        && auditRequest.targetIdentifier().equals(serviceCityResponse.cityIdentifier())
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("Deve expor listagem de cidades de atendimento pela API")
    void shouldExposeServiceCityListingThroughApi() throws Exception {
        // GIVEN
        ServiceCityResponse serviceCityResponse = new ServiceCityResponse(UUID.randomUUID(), "Esteio", "RS", "esteio-rs");
        when(listServiceCitiesUseCase.listServiceCities()).thenReturn(List.of(serviceCityResponse));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/cities"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].cityName").value("Esteio"));
    }

    @Test
    @DisplayName("Deve retornar erro de negocio quando categoria de servico for invalida")
    void shouldReturnBusinessErrorWhenServiceCategoryIsInvalid() throws Exception {
        // GIVEN
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal());
        when(registerServiceCategoryUseCase.registerServiceCategory(any(RegisterServiceCategoryRequest.class)))
                .thenThrow(new ApplicationRuleViolationException("O nome da categoria e obrigatorio."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/categories")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCategoryBody(""))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("O nome da categoria e obrigatorio."));
    }

    @Test
    @DisplayName("GIVEN campo fora do contrato WHEN cadastrar categoria THEN deve rejeitar sem coletar dado extra")
    void shouldRejectUnknownContractFieldWhenRegisteringServiceCategory() throws Exception {
        // GIVEN
        String requestBodyWithOutOfScopeField = """
                {
                  "categoryName": "Eletricista",
                  "creditCard": "4111111111111111"
                }
                """;

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/categories")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBodyWithOutOfScopeField))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("O corpo da requisicao contem campos invalidos ou fora do contrato."));
        verify(registerServiceCategoryUseCase, never()).registerServiceCategory(any(RegisterServiceCategoryRequest.class));
    }

    @Test
    @DisplayName("Deve negar cadastro administrativo de categoria para cliente")
    void shouldDenyAdministrativeServiceCategoryRegistrationForCustomer() throws Exception {
        // GIVEN
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.CUSTOMER
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER)).thenReturn(customerPrincipal);
        doThrow(new AuthorizationDeniedException("Acesso negado para este recurso."))
                .when(authorizeSensitiveActionUseCase)
                .authorizeSensitiveAction(customerPrincipal, SensitiveAction.REGISTER_SERVICE_CATEGORY);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/categories")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCategoryBody("Admin"))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Acesso negado para este recurso."));
        verify(recordSensitiveAuditEventUseCase, never()).recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }

    private AuthenticatedPrincipal administratorPrincipal() {
        return new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.ADMINISTRATOR);
    }

    private record ServiceCategoryBody(String categoryName) {
    }

    private record ServiceCityBody(String cityName, String stateCode) {
    }
}
