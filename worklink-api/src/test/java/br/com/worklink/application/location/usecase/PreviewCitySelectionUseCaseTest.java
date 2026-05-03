package br.com.worklink.application.location.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.catalog.port.LoadServiceCitiesByIdentifiersPort;
import br.com.worklink.application.location.port.SuggestNearbyServiceCitiesPort;
import br.com.worklink.domain.catalog.ServiceCity;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PreviewCitySelectionUseCaseTest {

    private static final ServiceCity CANOAS = ServiceCity.createServiceCity("Canoas", "RS", -29.9177, -51.1836);
    private static final ServiceCity ESTEIO = ServiceCity.createServiceCity("Esteio", "RS", -29.8520, -51.1841);
    private static final ServiceCity PORTO_ALEGRE = ServiceCity.createServiceCity("Porto Alegre", "RS", -30.0346, -51.2177);

    @Test
    @DisplayName("Deve selecionar uma cidade quando identificador existir")
    void shouldSelectOneCityWhenIdentifierExists() {
        // GIVEN
        PreviewCitySelectionUseCase previewCitySelectionUseCase = citySelectionUseCaseWithAvailableCities(List.of(CANOAS), List.of());

        // WHEN
        CitySelectionPreviewResponse citySelectionPreviewResponse = previewCitySelectionUseCase.previewCitySelection(
                new PreviewCitySelectionRequest(List.of(CANOAS.cityIdentifier()), Optional.empty())
        );

        // THEN
        assertThat(citySelectionPreviewResponse.selectedCities())
                .extracting(CitySelectionCityResponse::cityIdentifier)
                .containsExactly(CANOAS.cityIdentifier());
        assertThat(citySelectionPreviewResponse.currentLocationEnabled()).isFalse();
        assertThat(citySelectionPreviewResponse.nearbySuggestedCities()).isEmpty();
    }

    @Test
    @DisplayName("Deve selecionar mais de uma cidade quando identificadores existirem")
    void shouldSelectMoreThanOneCityWhenIdentifiersExist() {
        // GIVEN
        PreviewCitySelectionUseCase previewCitySelectionUseCase = citySelectionUseCaseWithAvailableCities(
                List.of(CANOAS, ESTEIO),
                List.of()
        );

        // WHEN
        CitySelectionPreviewResponse citySelectionPreviewResponse = previewCitySelectionUseCase.previewCitySelection(
                new PreviewCitySelectionRequest(List.of(CANOAS.cityIdentifier(), ESTEIO.cityIdentifier()), Optional.empty())
        );

        // THEN
        assertThat(citySelectionPreviewResponse.selectedCities())
                .extracting(CitySelectionCityResponse::cityIdentifier)
                .containsExactly(CANOAS.cityIdentifier(), ESTEIO.cityIdentifier());
    }

    @Test
    @DisplayName("Deve limpar selecao de cidades sem exigir login")
    void shouldClearCitySelectionWithoutRequiringLogin() {
        // GIVEN
        PreviewCitySelectionUseCase previewCitySelectionUseCase = citySelectionUseCaseWithAvailableCities(List.of(CANOAS), List.of());

        // WHEN
        CitySelectionPreviewResponse citySelectionPreviewResponse = previewCitySelectionUseCase.clearCitySelection();

        // THEN
        assertThat(citySelectionPreviewResponse.selectedCities()).isEmpty();
        assertThat(citySelectionPreviewResponse.currentLocationEnabled()).isFalse();
        assertThat(citySelectionPreviewResponse.nearbySuggestedCities()).isEmpty();
    }

    @Test
    @DisplayName("Deve aceitar previa vazia quando cidade e localizacao nao forem informadas")
    void shouldAcceptEmptyPreviewWhenCityAndLocationAreNotProvided() {
        // GIVEN
        PreviewCitySelectionUseCase previewCitySelectionUseCase = citySelectionUseCaseWithAvailableCities(List.of(CANOAS), List.of());

        // WHEN
        CitySelectionPreviewResponse citySelectionPreviewResponse = previewCitySelectionUseCase.previewCitySelection(
                new PreviewCitySelectionRequest(null, null)
        );

        // THEN
        assertThat(citySelectionPreviewResponse.selectedCities()).isEmpty();
        assertThat(citySelectionPreviewResponse.currentLocationEnabled()).isFalse();
        assertThat(citySelectionPreviewResponse.nearbySuggestedCities()).isEmpty();
    }

    @Test
    @DisplayName("Deve sugerir cidades proximas quando localizacao atual estiver ativa")
    void shouldSuggestNearbyCitiesWhenCurrentLocationIsEnabled() {
        // GIVEN
        PreviewCitySelectionUseCase previewCitySelectionUseCase = citySelectionUseCaseWithAvailableCities(
                List.of(CANOAS),
                List.of(ESTEIO, PORTO_ALEGRE)
        );
        CurrentLocationRequest currentLocationRequest = new CurrentLocationRequest(-29.91, -51.18);

        // WHEN
        CitySelectionPreviewResponse citySelectionPreviewResponse = previewCitySelectionUseCase.previewCitySelection(
                new PreviewCitySelectionRequest(List.of(CANOAS.cityIdentifier()), Optional.of(currentLocationRequest))
        );

        // THEN
        assertThat(citySelectionPreviewResponse.currentLocationEnabled()).isTrue();
        assertThat(citySelectionPreviewResponse.nearbySuggestedCities())
                .extracting(CitySelectionCityResponse::cityIdentifier)
                .containsExactly(ESTEIO.cityIdentifier(), PORTO_ALEGRE.cityIdentifier());
    }

    @Test
    @DisplayName("Deve rejeitar selecao quando uma cidade nao existir")
    void shouldRejectSelectionWhenAnyCityDoesNotExist() {
        // GIVEN
        PreviewCitySelectionUseCase previewCitySelectionUseCase = citySelectionUseCaseWithAvailableCities(List.of(CANOAS), List.of());

        // WHEN / THEN
        assertThatThrownBy(() -> previewCitySelectionUseCase.previewCitySelection(
                new PreviewCitySelectionRequest(List.of(CANOAS.cityIdentifier(), UUID.randomUUID()), Optional.empty())
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("Uma ou mais cidades selecionadas nao foram encontradas.");
    }

    @Test
    @DisplayName("Deve rejeitar localizacao atual quando coordenada for invalida")
    void shouldRejectCurrentLocationWhenCoordinateIsInvalid() {
        // GIVEN
        double invalidLatitude = 91.0;

        // WHEN / THEN
        assertThatThrownBy(() -> new CurrentLocationRequest(invalidLatitude, -51.18))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A latitude da localizacao atual deve estar entre -90 e 90.");
    }

    @Test
    @DisplayName("Deve rejeitar localizacao atual quando longitude for invalida")
    void shouldRejectCurrentLocationWhenLongitudeIsInvalid() {
        // GIVEN
        double invalidLongitude = -181.0;

        // WHEN / THEN
        assertThatThrownBy(() -> new CurrentLocationRequest(-29.91, invalidLongitude))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A longitude da localizacao atual deve estar entre -180 e 180.");
    }

    private PreviewCitySelectionUseCase citySelectionUseCaseWithAvailableCities(
            List<ServiceCity> selectedServiceCities,
            List<ServiceCity> nearbyServiceCities
    ) {
        LoadServiceCitiesByIdentifiersPort loadServiceCitiesByIdentifiersPort = cityIdentifiers -> selectedServiceCities.stream()
                .filter(serviceCity -> cityIdentifiers.contains(serviceCity.cityIdentifier()))
                .toList();
        SuggestNearbyServiceCitiesPort suggestNearbyServiceCitiesPort = (currentLocationRequest, maximumSuggestions) -> nearbyServiceCities
                .stream()
                .limit(maximumSuggestions)
                .toList();
        return new PreviewCitySelectionUseCase(loadServiceCitiesByIdentifiersPort, suggestNearbyServiceCitiesPort);
    }
}
