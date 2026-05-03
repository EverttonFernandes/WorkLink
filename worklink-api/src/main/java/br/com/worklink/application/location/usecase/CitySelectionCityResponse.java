package br.com.worklink.application.location.usecase;

import br.com.worklink.domain.catalog.ServiceCity;

import java.util.UUID;

public record CitySelectionCityResponse(
        UUID cityIdentifier,
        String cityName,
        String stateCode
) {

    static CitySelectionCityResponse fromServiceCity(ServiceCity serviceCity) {
        return new CitySelectionCityResponse(
                serviceCity.cityIdentifier(),
                serviceCity.cityName(),
                serviceCity.stateCode()
        );
    }
}
