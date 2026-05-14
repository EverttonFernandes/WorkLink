package br.com.worklink.api.customer;

public record UpdateCustomerProfilePreferencesHttpRequest(
        boolean whatsappNotificationsEnabled,
        boolean profilePersonalizationEnabled
) {
}
