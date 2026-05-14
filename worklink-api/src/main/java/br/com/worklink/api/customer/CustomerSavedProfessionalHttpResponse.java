package br.com.worklink.api.customer;

import br.com.worklink.application.customer.usecase.CustomerSavedProfessionalResponse;

import java.util.UUID;

public record CustomerSavedProfessionalHttpResponse(
        UUID professionalIdentifier,
        String professionalName,
        String categoryName,
        CustomerProfileCityHttpResponse city
) {

    static CustomerSavedProfessionalHttpResponse fromUseCaseResponse(
            CustomerSavedProfessionalResponse customerSavedProfessionalResponse
    ) {
        return new CustomerSavedProfessionalHttpResponse(
                customerSavedProfessionalResponse.professionalIdentifier(),
                customerSavedProfessionalResponse.professionalName(),
                customerSavedProfessionalResponse.categoryName(),
                CustomerProfileCityHttpResponse.fromUseCaseResponse(customerSavedProfessionalResponse.city())
        );
    }
}
