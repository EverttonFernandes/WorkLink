package br.com.worklink.application.customer.usecase;

import java.util.List;
import java.util.UUID;

public record CustomerProfileResponse(
        UUID customerIdentifier,
        String customerName,
        String phoneNumber,
        CustomerProfileCityResponse mainCity,
        List<CustomerProfileCityResponse> selectedCities,
        List<CustomerSavedProfessionalResponse> savedProfessionals,
        List<CustomerSubmittedReviewResponse> submittedReviews,
        boolean whatsappNotificationsEnabled,
        boolean profilePersonalizationEnabled
) {
}
