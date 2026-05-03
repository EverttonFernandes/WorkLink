package br.com.worklink.api.catalog;

import br.com.worklink.application.catalog.usecase.ServiceCityResponse;

import java.util.UUID;

public record ServiceCityHttpResponse(
        UUID cityIdentifier,
        String cityName,
        String stateCode,
        String citySlug
) {

    static ServiceCityHttpResponse fromServiceCityResponse(ServiceCityResponse serviceCityResponse) {
        return new ServiceCityHttpResponse(
                serviceCityResponse.cityIdentifier(),
                serviceCityResponse.cityName(),
                serviceCityResponse.stateCode(),
                serviceCityResponse.citySlug()
        );
    }
}
