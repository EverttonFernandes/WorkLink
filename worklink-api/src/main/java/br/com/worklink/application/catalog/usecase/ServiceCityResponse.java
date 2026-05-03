package br.com.worklink.application.catalog.usecase;

import br.com.worklink.domain.catalog.ServiceCity;

import java.util.UUID;

public record ServiceCityResponse(
        UUID cityIdentifier,
        String cityName,
        String stateCode,
        String citySlug
) {

    static ServiceCityResponse fromServiceCity(ServiceCity serviceCity) {
        return new ServiceCityResponse(
                serviceCity.cityIdentifier(),
                serviceCity.cityName(),
                serviceCity.stateCode(),
                serviceCity.citySlug()
        );
    }
}
