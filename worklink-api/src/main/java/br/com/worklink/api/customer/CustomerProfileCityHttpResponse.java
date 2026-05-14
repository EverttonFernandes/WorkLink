package br.com.worklink.api.customer;

import br.com.worklink.application.customer.usecase.CustomerProfileCityResponse;

import java.util.UUID;

public record CustomerProfileCityHttpResponse(
        UUID cityIdentifier,
        String cityName,
        String stateCode
) {

    static CustomerProfileCityHttpResponse fromUseCaseResponse(CustomerProfileCityResponse customerProfileCityResponse) {
        return new CustomerProfileCityHttpResponse(
                customerProfileCityResponse.cityIdentifier(),
                customerProfileCityResponse.cityName(),
                customerProfileCityResponse.stateCode()
        );
    }
}
