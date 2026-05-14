package br.com.worklink.application.customer.port;

public interface SaveCustomerProfilePreferencesPort {

    CustomerProfilePreferencesProjection saveCustomerProfilePreferences(
            CustomerProfilePreferencesProjection customerProfilePreferencesProjection
    );
}
