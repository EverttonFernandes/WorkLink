package br.com.worklink.application.customer.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

public record UpdateCustomerProfilePreferencesRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        boolean whatsappNotificationsEnabled,
        boolean profilePersonalizationEnabled
) {
}
