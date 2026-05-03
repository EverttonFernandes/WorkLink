package br.com.worklink.domain.catalog;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ServiceCategoryTest {

    @Test
    @DisplayName("Deve criar categoria de servico com slug normalizado quando nome for valido")
    void shouldCreateServiceCategoryWithNormalizedSlugWhenNameIsValid() {
        // GIVEN
        String categoryName = "Eletricista Residencial";

        // WHEN
        ServiceCategory serviceCategory = ServiceCategory.createServiceCategory(categoryName);

        // THEN
        assertThat(serviceCategory.categoryIdentifier()).isNotNull();
        assertThat(serviceCategory.categoryName()).isEqualTo(categoryName);
        assertThat(serviceCategory.categorySlug()).isEqualTo("eletricista-residencial");
    }

    @Test
    @DisplayName("Deve rejeitar categoria de servico quando nome estiver em branco")
    void shouldRejectServiceCategoryWhenNameIsBlank() {
        // GIVEN
        String categoryName = " ";

        // WHEN / THEN
        assertThatThrownBy(() -> ServiceCategory.createServiceCategory(categoryName))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O nome da categoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve restaurar categoria de servico persistida quando campos estiverem validos")
    void shouldRestorePersistedServiceCategoryWhenFieldsAreValid() {
        // GIVEN
        UUID categoryIdentifier = UUID.randomUUID();

        // WHEN
        ServiceCategory serviceCategory = ServiceCategory.restoreServiceCategory(
                categoryIdentifier,
                "Pedreiro",
                "pedreiro"
        );

        // THEN
        assertThat(serviceCategory.categoryIdentifier()).isEqualTo(categoryIdentifier);
        assertThat(serviceCategory.categoryName()).isEqualTo("Pedreiro");
        assertThat(serviceCategory.categorySlug()).isEqualTo("pedreiro");
    }

    @Test
    @DisplayName("Deve rejeitar restauracao de categoria quando identificador estiver ausente")
    void shouldRejectServiceCategoryRestorationWhenIdentifierIsMissing() {
        // GIVEN
        UUID categoryIdentifier = null;

        // WHEN / THEN
        assertThatThrownBy(() -> ServiceCategory.restoreServiceCategory(categoryIdentifier, "Pedreiro", "pedreiro"))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O identificador da categoria e obrigatorio.");
    }
}
