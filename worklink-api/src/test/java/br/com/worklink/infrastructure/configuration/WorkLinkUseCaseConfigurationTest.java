package br.com.worklink.infrastructure.configuration;

import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

class WorkLinkUseCaseConfigurationTest {

    @Test
    @DisplayName("Deve montar casos de uso a partir das portas configuradas")
    void shouldCreateUseCasesFromConfiguredPorts() {
        // GIVEN
        WorkLinkUseCaseConfiguration configuration = new WorkLinkUseCaseConfiguration();
        SaveServiceCategoryPort saveServiceCategoryPort = serviceCategory -> serviceCategory;
        ListServiceCategoriesPort listServiceCategoriesPort = java.util.List::of;
        SaveServiceCityPort saveServiceCityPort = serviceCity -> serviceCity;
        ListServiceCitiesPort listServiceCitiesPort = java.util.List::of;
        LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort = cityIdentifier -> Optional.empty();
        LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort = categoryIdentifier -> Optional.empty();
        SaveProfessionalPort saveProfessionalPort = professional -> professional;
        ListProfessionalsPort listProfessionalsPort = professionalSearchCriteria -> java.util.List.of();
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = professionalIdentifier -> Optional.empty();
        UpdateProfessionalPort updateProfessionalPort = professional -> professional;

        // WHEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = configuration.registerBasicProfessionalUseCase(
                loadServiceCityByIdentifierPort,
                loadServiceCategoryByIdentifierPort,
                saveProfessionalPort
        );

        // THEN
        assertThat(configuration.registerServiceCategoryUseCase(saveServiceCategoryPort)).isNotNull();
        assertThat(configuration.listServiceCategoriesUseCase(listServiceCategoriesPort)).isNotNull();
        assertThat(configuration.registerServiceCityUseCase(saveServiceCityPort)).isNotNull();
        assertThat(configuration.listServiceCitiesUseCase(listServiceCitiesPort)).isNotNull();
        assertThat(registerBasicProfessionalUseCase).isNotNull();
        assertThat(configuration.listProfessionalsUseCase(listProfessionalsPort)).isNotNull();
        assertThat(configuration.completeProfessionalProfileUseCase(
                loadProfessionalByIdentifierPort,
                updateProfessionalPort
        )).isNotNull();
    }
}
