package br.com.worklink.application.customer.usecase;

import java.util.UUID;

public record CustomerProfileCityResponse(
        UUID cityIdentifier,
        String cityName,
        String stateCode
) {
}
