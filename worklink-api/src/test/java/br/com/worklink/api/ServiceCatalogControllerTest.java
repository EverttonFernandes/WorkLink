package br.com.worklink.api;

import br.com.worklink.api.catalog.ServiceCatalogController;
import br.com.worklink.application.ApplicationRuleViolationException;
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
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ServiceCatalogController.class)
class ServiceCatalogControllerTest {

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

    @Test
    @DisplayName("Deve expor cadastro de categoria de servico pela API")
    void shouldExposeServiceCategoryRegistrationThroughApi() throws Exception {
        // GIVEN
        ServiceCategoryResponse serviceCategoryResponse = new ServiceCategoryResponse(UUID.randomUUID(), "Eletricista", "eletricista");
        when(registerServiceCategoryUseCase.registerServiceCategory(any(RegisterServiceCategoryRequest.class)))
                .thenReturn(serviceCategoryResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCategoryBody("Eletricista"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.categoryIdentifier").value(serviceCategoryResponse.categoryIdentifier().toString()))
                .andExpect(jsonPath("$.categoryName").value("Eletricista"))
                .andExpect(jsonPath("$.categorySlug").value("eletricista"));
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
        when(registerServiceCityUseCase.registerServiceCity(any(RegisterServiceCityRequest.class))).thenReturn(serviceCityResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/cities")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCityBody("Canoas", "RS"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.cityIdentifier").value(serviceCityResponse.cityIdentifier().toString()))
                .andExpect(jsonPath("$.cityName").value("Canoas"))
                .andExpect(jsonPath("$.stateCode").value("RS"))
                .andExpect(jsonPath("$.citySlug").value("canoas-rs"));
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
        when(registerServiceCategoryUseCase.registerServiceCategory(any(RegisterServiceCategoryRequest.class)))
                .thenThrow(new ApplicationRuleViolationException("O nome da categoria e obrigatorio."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ServiceCategoryBody(""))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("O nome da categoria e obrigatorio."));
    }

    private record ServiceCategoryBody(String categoryName) {
    }

    private record ServiceCityBody(String cityName, String stateCode) {
    }
}
