package br.com.worklink.application.customer.usecase;

import java.util.UUID;

public record CustomerSavedProfessionalResponse(
        UUID professionalIdentifier,
        String professionalName,
        String categoryName,
        CustomerProfileCityResponse city
) {
}
