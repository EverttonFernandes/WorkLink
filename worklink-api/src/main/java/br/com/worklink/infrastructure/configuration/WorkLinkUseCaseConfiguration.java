package br.com.worklink.infrastructure.configuration;

import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.application.catalog.usecase.ListServiceCategoriesUseCase;
import br.com.worklink.application.catalog.usecase.ListServiceCitiesUseCase;
import br.com.worklink.application.catalog.usecase.RegisterServiceCategoryUseCase;
import br.com.worklink.application.catalog.usecase.RegisterServiceCityUseCase;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.usecase.ListProfessionalsUseCase;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class WorkLinkUseCaseConfiguration {

    @Bean
    RegisterServiceCategoryUseCase registerServiceCategoryUseCase(SaveServiceCategoryPort saveServiceCategoryPort) {
        return new RegisterServiceCategoryUseCase(saveServiceCategoryPort);
    }

    @Bean
    ListServiceCategoriesUseCase listServiceCategoriesUseCase(ListServiceCategoriesPort listServiceCategoriesPort) {
        return new ListServiceCategoriesUseCase(listServiceCategoriesPort);
    }

    @Bean
    RegisterServiceCityUseCase registerServiceCityUseCase(SaveServiceCityPort saveServiceCityPort) {
        return new RegisterServiceCityUseCase(saveServiceCityPort);
    }

    @Bean
    ListServiceCitiesUseCase listServiceCitiesUseCase(ListServiceCitiesPort listServiceCitiesPort) {
        return new ListServiceCitiesUseCase(listServiceCitiesPort);
    }

    @Bean
    RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase(
            LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort,
            LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort,
            SaveProfessionalPort saveProfessionalPort
    ) {
        return new RegisterBasicProfessionalUseCase(
                loadServiceCityByIdentifierPort,
                loadServiceCategoryByIdentifierPort,
                saveProfessionalPort
        );
    }

    @Bean
    ListProfessionalsUseCase listProfessionalsUseCase(ListProfessionalsPort listProfessionalsPort) {
        return new ListProfessionalsUseCase(listProfessionalsPort);
    }
}
