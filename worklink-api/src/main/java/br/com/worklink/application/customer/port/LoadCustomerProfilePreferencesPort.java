package br.com.worklink.application.customer.port;

import java.util.Optional;
import java.util.UUID;

public interface LoadCustomerProfilePreferencesPort {

    Optional<CustomerProfilePreferencesProjection> loadCustomerProfilePreferences(UUID customerIdentifier);
}
