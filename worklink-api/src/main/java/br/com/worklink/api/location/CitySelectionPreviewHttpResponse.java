package br.com.worklink.api.location;

import br.com.worklink.application.location.usecase.CitySelectionPreviewResponse;

import java.util.List;

public record CitySelectionPreviewHttpResponse(
        List<CitySelectionCityHttpResponse> selectedCities,
        boolean currentLocationEnabled,
        List<CitySelectionCityHttpResponse> nearbySuggestedCities
) {

    static CitySelectionPreviewHttpResponse fromCitySelectionPreviewResponse(CitySelectionPreviewResponse citySelectionPreviewResponse) {
        return new CitySelectionPreviewHttpResponse(
                citySelectionPreviewResponse.selectedCities().stream()
                        .map(CitySelectionCityHttpResponse::fromCitySelectionCityResponse)
                        .toList(),
                citySelectionPreviewResponse.currentLocationEnabled(),
                citySelectionPreviewResponse.nearbySuggestedCities().stream()
                        .map(CitySelectionCityHttpResponse::fromCitySelectionCityResponse)
                        .toList()
        );
    }
}
