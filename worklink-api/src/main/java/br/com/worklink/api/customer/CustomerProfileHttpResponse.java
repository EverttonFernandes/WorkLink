package br.com.worklink.api.customer;

import br.com.worklink.application.customer.usecase.CustomerProfileResponse;

import java.util.List;
import java.util.UUID;

public record CustomerProfileHttpResponse(
        UUID customerIdentifier,
        String customerName,
        String phoneNumber,
        CustomerProfileCityHttpResponse mainCity,
        List<CustomerProfileCityHttpResponse> selectedCities,
        List<CustomerSavedProfessionalHttpResponse> savedProfessionals,
        List<CustomerSubmittedReviewHttpResponse> submittedReviews,
        boolean whatsappNotificationsEnabled,
        boolean profilePersonalizationEnabled
) {

    static CustomerProfileHttpResponse fromUseCaseResponse(CustomerProfileResponse customerProfileResponse) {
        return new CustomerProfileHttpResponse(
                customerProfileResponse.customerIdentifier(),
                customerProfileResponse.customerName(),
                customerProfileResponse.phoneNumber(),
                customerProfileResponse.mainCity() == null
                        ? null
                        : CustomerProfileCityHttpResponse.fromUseCaseResponse(customerProfileResponse.mainCity()),
                customerProfileResponse.selectedCities().stream()
                        .map(CustomerProfileCityHttpResponse::fromUseCaseResponse)
                        .toList(),
                customerProfileResponse.savedProfessionals().stream()
                        .map(CustomerSavedProfessionalHttpResponse::fromUseCaseResponse)
                        .toList(),
                customerProfileResponse.submittedReviews().stream()
                        .map(CustomerSubmittedReviewHttpResponse::fromUseCaseResponse)
                        .toList(),
                customerProfileResponse.whatsappNotificationsEnabled(),
                customerProfileResponse.profilePersonalizationEnabled()
        );
    }
}
