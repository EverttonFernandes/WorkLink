package br.com.worklink.application.location.usecase;

import java.util.List;

public record CitySelectionPreviewResponse(
        List<CitySelectionCityResponse> selectedCities,
        boolean currentLocationEnabled,
        List<CitySelectionCityResponse> nearbySuggestedCities
) {
}
