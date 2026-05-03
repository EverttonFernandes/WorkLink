package br.com.worklink.application.catalog.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.domain.catalog.ServiceCategory;
import br.com.worklink.domain.catalog.ServiceCity;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ServiceCatalogUseCaseTest {

    @Test
    @DisplayName("Deve registrar categoria de servico usando porta de persistencia")
    void shouldRegisterServiceCategoryUsingPersistencePort() {
        // GIVEN
        InMemoryServiceCategoryPort inMemoryServiceCategoryPort = new InMemoryServiceCategoryPort();
        RegisterServiceCategoryUseCase registerServiceCategoryUseCase = new RegisterServiceCategoryUseCase(inMemoryServiceCategoryPort);

        // WHEN
        ServiceCategoryResponse serviceCategoryResponse = registerServiceCategoryUseCase.registerServiceCategory(
                new RegisterServiceCategoryRequest("Encanador")
        );

        // THEN
        assertThat(serviceCategoryResponse.categoryName()).isEqualTo("Encanador");
        assertThat(inMemoryServiceCategoryPort.listServiceCategories())
                .extracting(ServiceCategory::categoryName)
                .containsExactly("Encanador");
    }

    @Test
    @DisplayName("Deve listar categorias de servico usando porta de leitura")
    void shouldListServiceCategoriesUsingReadPort() {
        // GIVEN
        InMemoryServiceCategoryPort inMemoryServiceCategoryPort = new InMemoryServiceCategoryPort();
        ServiceCategory serviceCategory = inMemoryServiceCategoryPort.saveServiceCategory(ServiceCategory.createServiceCategory("Pintor"));
        ListServiceCategoriesUseCase listServiceCategoriesUseCase = new ListServiceCategoriesUseCase(inMemoryServiceCategoryPort);

        // WHEN
        List<ServiceCategoryResponse> serviceCategories = listServiceCategoriesUseCase.listServiceCategories();

        // THEN
        assertThat(serviceCategories)
                .extracting(ServiceCategoryResponse::categoryIdentifier)
                .containsExactly(serviceCategory.categoryIdentifier());
    }

    @Test
    @DisplayName("Deve registrar cidade de atendimento usando porta de persistencia")
    void shouldRegisterServiceCityUsingPersistencePort() {
        // GIVEN
        InMemoryServiceCityPort inMemoryServiceCityPort = new InMemoryServiceCityPort();
        RegisterServiceCityUseCase registerServiceCityUseCase = new RegisterServiceCityUseCase(inMemoryServiceCityPort);

        // WHEN
        ServiceCityResponse serviceCityResponse = registerServiceCityUseCase.registerServiceCity(
                new RegisterServiceCityRequest("Canoas", "RS")
        );

        // THEN
        assertThat(serviceCityResponse.cityName()).isEqualTo("Canoas");
        assertThat(inMemoryServiceCityPort.listServiceCities())
                .extracting(ServiceCity::cityName)
                .containsExactly("Canoas");
    }

    @Test
    @DisplayName("Deve listar cidades de atendimento usando porta de leitura")
    void shouldListServiceCitiesUsingReadPort() {
        // GIVEN
        InMemoryServiceCityPort inMemoryServiceCityPort = new InMemoryServiceCityPort();
        ServiceCity serviceCity = inMemoryServiceCityPort.saveServiceCity(ServiceCity.createServiceCity("Esteio", "RS"));
        ListServiceCitiesUseCase listServiceCitiesUseCase = new ListServiceCitiesUseCase(inMemoryServiceCityPort);

        // WHEN
        List<ServiceCityResponse> serviceCities = listServiceCitiesUseCase.listServiceCities();

        // THEN
        assertThat(serviceCities)
                .extracting(ServiceCityResponse::cityIdentifier)
                .containsExactly(serviceCity.cityIdentifier());
    }

    @Test
    @DisplayName("Deve traduzir erro de dominio quando categoria de servico for invalida")
    void shouldTranslateDomainErrorWhenServiceCategoryIsInvalid() {
        // GIVEN
        RegisterServiceCategoryUseCase registerServiceCategoryUseCase = new RegisterServiceCategoryUseCase(
                serviceCategory -> serviceCategory
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerServiceCategoryUseCase.registerServiceCategory(new RegisterServiceCategoryRequest("")))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O nome da categoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve traduzir erro de dominio quando cidade de atendimento for invalida")
    void shouldTranslateDomainErrorWhenServiceCityIsInvalid() {
        // GIVEN
        RegisterServiceCityUseCase registerServiceCityUseCase = new RegisterServiceCityUseCase(serviceCity -> serviceCity);

        // WHEN / THEN
        assertThatThrownBy(() -> registerServiceCityUseCase.registerServiceCity(new RegisterServiceCityRequest("Canoas", "R1")))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A UF da cidade deve possuir exatamente duas letras.");
    }

    private static class InMemoryServiceCategoryPort implements SaveServiceCategoryPort, ListServiceCategoriesPort {

        private final List<ServiceCategory> serviceCategories = new ArrayList<>();

        @Override
        public ServiceCategory saveServiceCategory(ServiceCategory serviceCategory) {
            serviceCategories.add(serviceCategory);
            return serviceCategory;
        }

        @Override
        public List<ServiceCategory> listServiceCategories() {
            return List.copyOf(serviceCategories);
        }
    }

    private static class InMemoryServiceCityPort implements SaveServiceCityPort, ListServiceCitiesPort {

        private final List<ServiceCity> serviceCities = new ArrayList<>();

        @Override
        public ServiceCity saveServiceCity(ServiceCity serviceCity) {
            serviceCities.add(serviceCity);
            return serviceCity;
        }

        @Override
        public List<ServiceCity> listServiceCities() {
            return List.copyOf(serviceCities);
        }
    }
}
