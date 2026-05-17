package br.com.worklink.application.customer.port;

@FunctionalInterface
public interface SaveCustomerProfilePreferencesPort {

    CustomerProfilePreferencesProjection saveCustomerProfilePreferences(
            CustomerProfilePreferencesProjection customerProfilePreferencesProjection
    );
}
