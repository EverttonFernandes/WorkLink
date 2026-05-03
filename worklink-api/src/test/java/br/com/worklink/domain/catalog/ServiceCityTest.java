package br.com.worklink.domain.catalog;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ServiceCityTest {

    @Test
    @DisplayName("Deve criar cidade de atendimento com slug normalizado quando campos forem validos")
    void shouldCreateServiceCityWithNormalizedSlugWhenFieldsAreValid() {
        // GIVEN
        String cityName = "São Leopoldo";
        String stateCode = "rs";

        // WHEN
        ServiceCity serviceCity = ServiceCity.createServiceCity(cityName, stateCode);

        // THEN
        assertThat(serviceCity.cityIdentifier()).isNotNull();
        assertThat(serviceCity.cityName()).isEqualTo(cityName);
        assertThat(serviceCity.stateCode()).isEqualTo("RS");
        assertThat(serviceCity.citySlug()).isEqualTo("sao-leopoldo-rs");
    }

    @Test
    @DisplayName("Deve rejeitar cidade de atendimento quando UF possuir formato invalido")
    void shouldRejectServiceCityWhenStateCodeHasInvalidFormat() {
        // GIVEN
        String stateCode = "RS1";

        // WHEN / THEN
        assertThatThrownBy(() -> ServiceCity.createServiceCity("Porto Alegre", stateCode))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A UF da cidade deve possuir exatamente duas letras.");
    }

    @Test
    @DisplayName("Deve restaurar cidade de atendimento persistida quando campos estiverem validos")
    void shouldRestorePersistedServiceCityWhenFieldsAreValid() {
        // GIVEN
        UUID cityIdentifier = UUID.randomUUID();

        // WHEN
        ServiceCity serviceCity = ServiceCity.restoreServiceCity(cityIdentifier, "Canoas", "RS", "canoas-rs");

        // THEN
        assertThat(serviceCity.cityIdentifier()).isEqualTo(cityIdentifier);
        assertThat(serviceCity.cityName()).isEqualTo("Canoas");
        assertThat(serviceCity.stateCode()).isEqualTo("RS");
        assertThat(serviceCity.citySlug()).isEqualTo("canoas-rs");
    }

    @Test
    @DisplayName("Deve rejeitar cidade de atendimento quando nome estiver ausente")
    void shouldRejectServiceCityWhenNameIsMissing() {
        // GIVEN
        String cityName = null;

        // WHEN / THEN
        assertThatThrownBy(() -> ServiceCity.createServiceCity(cityName, "RS"))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O nome da cidade e obrigatorio.");
    }
}
