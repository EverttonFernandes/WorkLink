package br.com.worklink.application.location.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.catalog.port.LoadServiceCitiesByIdentifiersPort;
import br.com.worklink.application.location.port.SuggestNearbyServiceCitiesPort;
import br.com.worklink.domain.catalog.ServiceCity;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public class PreviewCitySelectionUseCase {

    private static final int MAXIMUM_NEARBY_CITY_SUGGESTIONS = 5;

    private final LoadServiceCitiesByIdentifiersPort loadServiceCitiesByIdentifiersPort;
    private final SuggestNearbyServiceCitiesPort suggestNearbyServiceCitiesPort;

    public PreviewCitySelectionUseCase(
            LoadServiceCitiesByIdentifiersPort loadServiceCitiesByIdentifiersPort,
            SuggestNearbyServiceCitiesPort suggestNearbyServiceCitiesPort
    ) {
        this.loadServiceCitiesByIdentifiersPort = loadServiceCitiesByIdentifiersPort;
        this.suggestNearbyServiceCitiesPort = suggestNearbyServiceCitiesPort;
    }

    public CitySelectionPreviewResponse previewCitySelection(PreviewCitySelectionRequest request) {
        Set<UUID> uniqueSelectedCityIdentifiers = new LinkedHashSet<>(request.selectedCityIdentifiers());
        List<ServiceCity> selectedServiceCities = loadSelectedServiceCities(uniqueSelectedCityIdentifiers);
        List<ServiceCity> nearbyServiceCities = request.currentLocationRequest()
                .map(currentLocationRequest -> suggestNearbyServiceCitiesPort.suggestNearbyServiceCities(
                        currentLocationRequest,
                        MAXIMUM_NEARBY_CITY_SUGGESTIONS
                ))
                .orElse(List.of());

        return new CitySelectionPreviewResponse(
                selectedServiceCities.stream().map(CitySelectionCityResponse::fromServiceCity).toList(),
                request.currentLocationRequest().isPresent(),
                nearbyServiceCities.stream().map(CitySelectionCityResponse::fromServiceCity).toList()
        );
    }

    public CitySelectionPreviewResponse clearCitySelection() {
        return new CitySelectionPreviewResponse(List.of(), false, List.of());
    }

    private List<ServiceCity> loadSelectedServiceCities(Set<UUID> uniqueSelectedCityIdentifiers) {
        if (uniqueSelectedCityIdentifiers.isEmpty()) {
            return List.of();
        }
        List<ServiceCity> selectedServiceCities = loadServiceCitiesByIdentifiersPort.loadServiceCitiesByIdentifiers(
                uniqueSelectedCityIdentifiers
        );
        if (selectedServiceCities.size() != uniqueSelectedCityIdentifiers.size()) {
            throw new ApplicationRuleViolationException("Uma ou mais cidades selecionadas nao foram encontradas.");
        }
        return selectedServiceCities;
    }
}
