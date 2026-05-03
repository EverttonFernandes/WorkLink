package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.domain.catalog.ServiceCategory;
import br.com.worklink.domain.catalog.ServiceCity;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalProfileClassification;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalUseCaseTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("Deve registrar profissional basico quando cidade e categoria existirem")
    void shouldRegisterBasicProfessionalWhenCityAndCategoryExist() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                cityIdentifier -> Optional.of(ServiceCity.restoreServiceCity(cityIdentifier, "Canoas", "RS", "canoas-rs")),
                categoryIdentifier -> Optional.of(ServiceCategory.restoreServiceCategory(categoryIdentifier, "Eletricista", "eletricista")),
                inMemoryProfessionalPort
        );

        // WHEN
        ProfessionalResponse professionalResponse = registerBasicProfessionalUseCase.registerBasicProfessional(validProfessionalRequest());

        // THEN
        assertThat(professionalResponse.profileClassification()).isEqualTo(ProfessionalProfileClassification.BASIC_PROFILE.name());
        assertThat(professionalResponse.qualityGuarantee()).isFalse();
        assertThat(inMemoryProfessionalPort.listProfessionals(ProfessionalSearchCriteria.withoutFilters()))
                .extracting(Professional::professionalIdentifier)
                .containsExactly(professionalResponse.professionalIdentifier());
    }

    @Test
    @DisplayName("Deve rejeitar profissional basico quando cidade nao existir")
    void shouldRejectBasicProfessionalWhenCityDoesNotExist() {
        // GIVEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                missingCityPort(),
                existingCategoryPort(),
                professional -> professional
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerBasicProfessionalUseCase.registerBasicProfessional(validProfessionalRequest()))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A cidade informada para o profissional nao foi encontrada.");
    }

    @Test
    @DisplayName("Deve rejeitar profissional basico quando categoria nao existir")
    void shouldRejectBasicProfessionalWhenCategoryDoesNotExist() {
        // GIVEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                existingCityPort(),
                missingCategoryPort(),
                professional -> professional
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerBasicProfessionalUseCase.registerBasicProfessional(validProfessionalRequest()))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A categoria informada para o profissional nao foi encontrada.");
    }

    @Test
    @DisplayName("Deve traduzir erro de dominio quando profissional basico estiver sem campo minimo")
    void shouldTranslateDomainErrorWhenBasicProfessionalHasMissingMinimumField() {
        // GIVEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                existingCityPort(),
                existingCategoryPort(),
                professional -> professional
        );
        RegisterBasicProfessionalRequest request = new RegisterBasicProfessionalRequest(
                "",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerBasicProfessionalUseCase.registerBasicProfessional(request))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O nome do profissional e obrigatorio.");
    }

    @Test
    @DisplayName("Deve listar profissionais usando criterio de busca informado")
    void shouldListProfessionalsUsingProvidedSearchCriteria() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        ListProfessionalsUseCase listProfessionalsUseCase = new ListProfessionalsUseCase(inMemoryProfessionalPort);
        ProfessionalSearchCriteria professionalSearchCriteria = new ProfessionalSearchCriteria(
                Optional.of(CATEGORY_IDENTIFIER),
                Set.of(CITY_IDENTIFIER),
                Optional.of("residencial")
        );

        // WHEN
        List<ProfessionalResponse> professionals = listProfessionalsUseCase.listProfessionals(professionalSearchCriteria);

        // THEN
        assertThat(professionals)
                .extracting(ProfessionalResponse::professionalIdentifier)
                .containsExactly(professional.professionalIdentifier());
    }

    private RegisterBasicProfessionalRequest validProfessionalRequest() {
        return new RegisterBasicProfessionalRequest(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
    }

    private LoadServiceCityByIdentifierPort existingCityPort() {
        return cityIdentifier -> Optional.of(ServiceCity.restoreServiceCity(cityIdentifier, "Canoas", "RS", "canoas-rs"));
    }

    private LoadServiceCityByIdentifierPort missingCityPort() {
        return cityIdentifier -> Optional.empty();
    }

    private LoadServiceCategoryByIdentifierPort existingCategoryPort() {
        return categoryIdentifier -> Optional.of(ServiceCategory.restoreServiceCategory(categoryIdentifier, "Eletricista", "eletricista"));
    }

    private LoadServiceCategoryByIdentifierPort missingCategoryPort() {
        return categoryIdentifier -> Optional.empty();
    }

    private static class InMemoryProfessionalPort implements SaveProfessionalPort, ListProfessionalsPort {

        private final List<Professional> professionals = new ArrayList<>();

        @Override
        public Professional saveProfessional(Professional professional) {
            professionals.add(professional);
            return professional;
        }

        @Override
        public List<Professional> listProfessionals(ProfessionalSearchCriteria professionalSearchCriteria) {
            return professionals.stream()
                    .filter(professional -> professionalSearchCriteria.categoryIdentifier()
                            .map(professional.categoryIdentifier()::equals)
                            .orElse(true))
                    .filter(professional -> professionalSearchCriteria.cityIdentifiers().isEmpty()
                            || professionalSearchCriteria.cityIdentifiers().contains(professional.cityIdentifier()))
                    .filter(professional -> professionalSearchCriteria.keyword()
                            .map(keyword -> professional.professionalName().toLowerCase().contains(keyword.toLowerCase())
                                    || professional.shortDescription().toLowerCase().contains(keyword.toLowerCase()))
                            .orElse(true))
                    .toList();
        }
    }
}
