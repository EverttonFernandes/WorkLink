package br.com.worklink.api.location;

import br.com.worklink.application.location.usecase.CitySelectionCityResponse;

import java.util.UUID;

public record CitySelectionCityHttpResponse(
        UUID cityIdentifier,
        String cityName,
        String stateCode
) {

    static CitySelectionCityHttpResponse fromCitySelectionCityResponse(CitySelectionCityResponse citySelectionCityResponse) {
        return new CitySelectionCityHttpResponse(
                citySelectionCityResponse.cityIdentifier(),
                citySelectionCityResponse.cityName(),
                citySelectionCityResponse.stateCode()
        );
    }
}
